package com.bikerental.service;

import java.io.File;
import java.nio.file.Files;
import java.nio.file.Paths;
import java.nio.file.StandardCopyOption;
import java.sql.Timestamp;
import java.time.LocalDate;
import java.time.temporal.ChronoUnit;
import com.bikerental.dao.BookingDao;
import com.bikerental.dao.CouponDao;
import com.bikerental.dao.PaymentDao;
import com.bikerental.dao.RefundLogDao;
import com.bikerental.dao.NotificationDao;
import com.bikerental.dao.PenaltyDao;
import com.bikerental.dao.AccidentReportDao;
import com.bikerental.dao.FuelLogDao;
import com.bikerental.dto.BookingDto;
import com.bikerental.dto.PaymentDto;
import com.bikerental.dto.RefundLogDto;
import com.bikerental.dto.PenaltyDto;
import com.bikerental.dto.AccidentReportDto;
import com.bikerental.dto.FuelLogDto;

public class BookingService {
    private static BookingService instance = new BookingService();

    private BookingService() {}

    public static BookingService getInstance() {
        return instance;
    }

    public int createBooking(BookingDto dto, String couponIdStr) {
        int r = BookingDao.getInstance().insertBooking(dto);
        if (r > 0) {
            if (couponIdStr != null && !couponIdStr.trim().isEmpty() && !"none".equals(couponIdStr)) {
                try {
                    int couponId = Integer.parseInt(couponIdStr);
                    CouponDao.getInstance().updateCouponStatus(couponId, "USED");
                } catch (Exception e) {
                    e.printStackTrace();
                }
            }
        }
        return r;
    }

    public void updateBookingStatus(int bookingId, String status) {
        BookingDao.getInstance().updateBookingStatus(bookingId, status);
    }

    public void cancelBooking(int bookingId, int memberId, boolean isAdmin) {
        BookingDto booking = BookingDao.getInstance().getBooking(bookingId);
        if (booking != null && (booking.getMemberId() == memberId || isAdmin)) {
            BookingDao.getInstance().updateBookingStatus(bookingId, "CANCELLED");

            PaymentDto payment = PaymentDao.getInstance().getPaymentByReservation(bookingId);
            if (payment != null) {
                Timestamp startDate = booking.getStartDate();
                LocalDate startLocalDate = startDate.toLocalDateTime().toLocalDate();
                LocalDate currentLocalDate = LocalDate.now();
                long diffDays = ChronoUnit.DAYS.between(currentLocalDate, startLocalDate);

                int penaltyRate = 0;
                if (diffDays >= 3) {
                    penaltyRate = 0;
                } else if (diffDays >= 1) {
                    penaltyRate = 50;
                } else {
                    penaltyRate = 100;
                }

                int refundAmt = (int) (payment.getAmount() * (100 - penaltyRate) / 100.0);
                PaymentDao.getInstance().updatePaymentStatus(payment.getPaymentId(), "전체취소", refundAmt);

                RefundLogDto rlog = new RefundLogDto();
                rlog.setPaymentId(payment.getPaymentId());
                rlog.setPenaltyRate(penaltyRate);
                rlog.setRefundAmount(refundAmt);
                rlog.setRefundMethod(payment.getPaymentMethod());
                rlog.setStatus("완료");
                RefundLogDao.getInstance().insertRefund(rlog);

                String notiContent = "💳 결제 취소 및 환불 안내: 예약 #" + bookingId + "이 취소되었습니다. (위약금 " + penaltyRate + "%, 환불금액: ₩" + String.format("%,d", refundAmt) + "원)";
                NotificationDao.send(booking.getMemberId(), "알림톡", notiContent);
            }
        }
    }

    public void cancelPayment(int paymentId, String cancelType, int cancelAmt, int memberId, boolean isAdmin) {
        PaymentDto pay = PaymentDao.getInstance().getPayment(paymentId);
        if (pay != null) {
            boolean isAuthorized = isAdmin;
            if (!isAuthorized) {
                BookingDto booking = BookingDao.getInstance().getBooking(pay.getReservationId());
                if (booking != null && booking.getMemberId() == memberId) {
                    isAuthorized = true;
                }
            }
            
            if (isAuthorized) {
                String newStatus = "전체취소";
                if ("PARTIAL".equals(cancelType)) {
                    newStatus = "부분취소";
                }
                
                int newRefundAmt = pay.getRefundAmount() + cancelAmt;
                if (newRefundAmt > pay.getAmount()) {
                    newRefundAmt = pay.getAmount();
                }
                PaymentDao.getInstance().updatePaymentStatus(paymentId, newStatus, newRefundAmt);
                
                if ("전체취소".equals(newStatus)) {
                    BookingDao.getInstance().updateBookingStatus(pay.getReservationId(), "CANCELLED");
                }

                int penaltyRate = (int) Math.round((1.0 - (double)cancelAmt / pay.getAmount()) * 100.0);
                if (penaltyRate < 0) penaltyRate = 0;
                if (penaltyRate > 100) penaltyRate = 100;
                
                RefundLogDto rlog = new RefundLogDto();
                rlog.setPaymentId(paymentId);
                rlog.setPenaltyRate(penaltyRate);
                rlog.setRefundAmount(cancelAmt);
                rlog.setRefundMethod(pay.getPaymentMethod());
                rlog.setStatus("완료");
                RefundLogDao.getInstance().insertRefund(rlog);
                
                try {
                    BookingDto booking = BookingDao.getInstance().getBooking(pay.getReservationId());
                    if (booking != null) {
                        String notiContent = "💳 결제 취소 안내: [" + newStatus + "] 처리 완료 (취소 및 환불금액: ₩" + String.format("%,d", cancelAmt) + "원)";
                        NotificationDao.send(booking.getMemberId(), "알림톡", notiContent);
                    }
                } catch (Exception ex) {
                    ex.printStackTrace();
                }
            }
        }
    }

    public void payPenalty(int penaltyId) {
        PenaltyDao.getInstance().payPenalty(penaltyId);
    }

    public void addPenalty(PenaltyDto dto) {
        PenaltyDao.getInstance().insertPenalty(dto);
    }

    public void reportAccident(AccidentReportDto dto, jakarta.servlet.http.Part filePart, String deployDir, String srcDir) throws Exception {
        String imageFilename = null;
        if (filePart != null && filePart.getSize() > 0) {
            String originalName = filePart.getSubmittedFileName();
            String extension = "";
            int dotIndex = originalName.lastIndexOf('.');
            if (dotIndex > 0) {
                extension = originalName.substring(dotIndex);
            }
            imageFilename = "accident_" + System.currentTimeMillis() + extension;
            
            File uploadDir = new File(deployDir);
            if (!uploadDir.exists()) {
                uploadDir.mkdirs();
            }
            String deployFilePath = deployDir + File.separator + imageFilename;
            filePart.write(deployFilePath);
            
            File srcUploadDir = new File(srcDir);
            if (!srcUploadDir.exists()) {
                srcUploadDir.mkdirs();
            }
            try {
                Files.copy(
                    Paths.get(deployFilePath),
                    Paths.get(srcDir + File.separator + imageFilename),
                    StandardCopyOption.REPLACE_EXISTING
                );
            } catch (Exception e) {
                e.printStackTrace();
            }
        }
        if (imageFilename != null) {
            dto.setPhotoPath("resources/images/accidents/" + imageFilename);
        }
        
        AccidentReportDao.getInstance().insertReport(dto);
        
        try {
            NotificationDao.send(dto.getUserId(), "앱푸시", "🚨 사고 접수가 완료되었습니다. 담당자가 신속히 확인하여 보험 처리를 도와드리겠습니다.");
        } catch(Exception ex) {
            ex.printStackTrace();
        }
    }

    public void updateAccidentReport(int reportId, String status, String claimNum, int faultRatio) {
        AccidentReportDao.getInstance().updateReportStatus(reportId, status, claimNum, faultRatio);
        
        try {
            AccidentReportDto report = AccidentReportDao.getInstance().getReport(reportId);
            if (report != null) {
                String notiText = "🚨 사고 접수 #" + reportId + "번의 처리 상태가 [" + status + "]으로 변경되었습니다.";
                if ("손해사정중".equals(status)) {
                    notiText += " (보험접수번호: " + claimNum + ", 과실비율: " + faultRatio + "%)";
                } else if ("종결".equals(status)) {
                    notiText += " 보험 처리가 최종 종결되었습니다. 마이페이지에서 상세 내역을 확인하세요.";
                }
                NotificationDao.send(report.getUserId(), "알림톡", notiText);
            }
        } catch(Exception ex) {
            ex.printStackTrace();
        }
    }

    public void addFuelLog(int reservationId, int fuelLevel) {
        int penaltyAmount = 0;
        if (fuelLevel < 100) {
            penaltyAmount = (100 - fuelLevel) * 1000;
        }
        
        FuelLogDto dto = new FuelLogDto();
        dto.setReservationId(reservationId);
        dto.setFuelLevel(fuelLevel);
        dto.setPenaltyAmount(penaltyAmount);
        
        FuelLogDao.getInstance().insertFuelLogAndUpdateBooking(dto);
        
        try {
            BookingDto booking = BookingDao.getInstance().getBooking(reservationId);
            if (booking != null) {
                String notiText = "🏍️ 바이크 반납 처리가 완료되었습니다. (반납 시 주유량: " + fuelLevel + "%)";
                if (penaltyAmount > 0) {
                    notiText += " 주유량 미달 패널티 ₩" + String.format("%,d", penaltyAmount) + "원이 고지되었습니다. 마이페이지에서 상세 내역을 확인해 주세요.";
                } else {
                    notiText += " 주유 상태 정상 확인되었습니다. 이용해 주셔서 감사합니다!";
                }
                NotificationDao.send(booking.getMemberId(), "알림톡", notiText);
            }
        } catch (Exception ex) {
            ex.printStackTrace();
        }
    }
}
