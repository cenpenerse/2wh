package com.bikerental.controller;

import java.io.IOException;
import java.util.Map;
import jakarta.servlet.ServletException;
import jakarta.servlet.annotation.MultipartConfig;
import jakarta.servlet.annotation.WebServlet;
import jakarta.servlet.http.HttpServlet;
import jakarta.servlet.http.HttpServletRequest;
import jakarta.servlet.http.HttpServletResponse;
import jakarta.servlet.http.HttpSession;
import com.bikerental.dto.MemberDto;
import com.bikerental.dto.BoardDto;
import com.bikerental.dto.CommentDto;
import com.bikerental.dto.InquiryDto;
import com.bikerental.dto.ReviewDto;
import com.bikerental.service.BoardService;

@WebServlet("/board/*")
@MultipartConfig(
    maxFileSize = 1024 * 1024 * 10,     // 10MB
    maxRequestSize = 1024 * 1024 * 20,   // 20MB
    fileSizeThreshold = 0
)
public class BoardController extends HttpServlet {
    private static final long serialVersionUID = 1L;

    protected void doGet(HttpServletRequest request, HttpServletResponse response) throws ServletException, IOException {
        processRequest(request, response);
    }

    protected void doPost(HttpServletRequest request, HttpServletResponse response) throws ServletException, IOException {
        processRequest(request, response);
    }

    private void processRequest(HttpServletRequest request, HttpServletResponse response) throws ServletException, IOException {
        request.setCharacterEncoding("UTF-8");
        response.setContentType("text/html; charset=UTF-8");

        String uri = request.getRequestURI();
        String contextPath = request.getContextPath();
        String command = uri.substring(contextPath.length());
        
        System.out.println("[BoardController] Requested Command: " + command);

        String viewPage = null;
        boolean isRedirect = false;

        try {
            if (command.equals("/board/boardList.do")) {
                String boardType = request.getParameter("boardType");
                if (boardType == null || boardType.isEmpty()) {
                    boardType = "FREE";
                }
                String pageParam = request.getParameter("page");
                
                Map<String, Object> listData = BoardService.getInstance().getBoardList(boardType, pageParam);
                request.setAttribute("postList", listData.get("postList"));
                request.setAttribute("paging", listData.get("paging"));
                request.setAttribute("boardType", boardType);
                
                viewPage = "/WEB-INF/views/board/list.jsp";
                
            } else if (command.equals("/board/boardDetail.do")) {
                int postId = Integer.parseInt(request.getParameter("postId"));
                
                Map<String, Object> detailData = BoardService.getInstance().getBoardDetail(postId);
                request.setAttribute("post", detailData.get("post"));
                request.setAttribute("commentList", detailData.get("commentList"));
                
                viewPage = "/WEB-INF/views/board/detail.jsp";
                
            } else if (command.equals("/board/boardWrite.do")) {
                HttpSession session = request.getSession(false);
                MemberDto loginUser = (session != null) ? (MemberDto) session.getAttribute("loginUser") : null;
                
                if (loginUser == null) {
                    isRedirect = true;
                    viewPage = contextPath + "/member/login.do";
                } else {
                    request.setAttribute("boardType", request.getParameter("boardType"));
                    viewPage = "/WEB-INF/views/board/write.jsp";
                }
                
            } else if (command.equals("/board/boardWriteAction.do")) {
                HttpSession session = request.getSession(false);
                MemberDto loginUser = (session != null) ? (MemberDto) session.getAttribute("loginUser") : null;
                
                if (loginUser == null) {
                    isRedirect = true;
                    viewPage = contextPath + "/member/login.do";
                } else {
                    String boardType = request.getParameter("boardType");
                    String title = request.getParameter("title");
                    String content = request.getParameter("content");
                    
                    BoardDto dto = new BoardDto();
                    dto.setMemberId(loginUser.getMemberId());
                    dto.setTitle(title);
                    dto.setContent(content);
                    dto.setBoardType(boardType);
                    
                    jakarta.servlet.http.Part filePart = request.getPart("attachedFile");
                    String deployDir = request.getServletContext().getRealPath("/resources/upload");
                    String srcDir = "c:\\2_eclipse\\hp\\bikerental\\src\\main\\webapp\\resources\\upload";
                    
                    BoardService.getInstance().writePost(dto, filePart, deployDir, srcDir);
                    
                    isRedirect = true;
                    viewPage = contextPath + "/board/boardList.do?boardType=" + boardType;
                }
                
            } else if (command.equals("/board/boardUpdate.do")) {
                int postId = Integer.parseInt(request.getParameter("postId"));
                BoardDto post = BoardService.getInstance().getPost(postId);
                request.setAttribute("post", post);
                viewPage = "/WEB-INF/views/board/update.jsp";
                
            } else if (command.equals("/board/boardUpdateAction.do")) {
                int postId = Integer.parseInt(request.getParameter("postId"));
                String title = request.getParameter("title");
                String content = request.getParameter("content");
                String deleteExistingStr = request.getParameter("deleteExistingFile");
                boolean deleteExisting = "true".equals(deleteExistingStr);
                
                jakarta.servlet.http.Part filePart = request.getPart("attachedFile");
                String deployDir = request.getServletContext().getRealPath("/resources/upload");
                String srcDir = "c:\\2_eclipse\\hp\\bikerental\\src\\main\\webapp\\resources\\upload";
                
                BoardService.getInstance().updatePost(postId, title, content, deleteExisting, filePart, deployDir, srcDir);
                
                isRedirect = true;
                viewPage = contextPath + "/board/boardDetail.do?postId=" + postId;
                
            } else if (command.equals("/board/boardDeleteAction.do")) {
                int postId = Integer.parseInt(request.getParameter("postId"));
                String boardType = request.getParameter("boardType");
                
                String deployDir = request.getServletContext().getRealPath("/resources/upload");
                String srcDir = "c:\\2_eclipse\\hp\\bikerental\\src\\main\\webapp\\resources\\upload";
                
                BoardService.getInstance().deletePost(postId, deployDir, srcDir);
                
                isRedirect = true;
                viewPage = contextPath + "/board/boardList.do?boardType=" + boardType;
                
            } else if (command.equals("/board/commentWriteAction.do")) {
                HttpSession session = request.getSession(false);
                MemberDto loginUser = (session != null) ? (MemberDto) session.getAttribute("loginUser") : null;
                
                if (loginUser == null) {
                    isRedirect = true;
                    viewPage = contextPath + "/member/login.do";
                } else {
                    int postId = Integer.parseInt(request.getParameter("postId"));
                    String content = request.getParameter("content");
                    
                    CommentDto dto = new CommentDto();
                    dto.setPostId(postId);
                    dto.setMemberId(loginUser.getMemberId());
                    dto.setContent(content);
                    
                    BoardService.getInstance().writeComment(dto);
                    
                    isRedirect = true;
                    viewPage = contextPath + "/board/boardDetail.do?postId=" + postId;
                }
                
            } else if (command.equals("/board/commentDeleteAction.do")) {
                int commentId = Integer.parseInt(request.getParameter("commentId"));
                int postId = Integer.parseInt(request.getParameter("postId"));
                
                BoardService.getInstance().deleteComment(commentId);
                
                isRedirect = true;
                viewPage = contextPath + "/board/boardDetail.do?postId=" + postId;
                
            } else if (command.equals("/board/inquiryAction.do")) {
                HttpSession session = request.getSession(false);
                MemberDto loginUser = (session != null) ? (MemberDto) session.getAttribute("loginUser") : null;
                if (loginUser == null) {
                    isRedirect = true;
                    viewPage = contextPath + "/member/login.do";
                } else {
                    String title = request.getParameter("title");
                    String content = request.getParameter("content");
                    
                    InquiryDto dto = new InquiryDto();
                    dto.setUserId(loginUser.getMemberId());
                    dto.setTitle(title);
                    dto.setContent(content);
                    
                    BoardService.getInstance().submitInquiry(dto);
                    
                    isRedirect = true;
                    viewPage = contextPath + "/member/mypage.do";
                }
                
            } else if (command.equals("/board/adminInquiryAnswer.do")) {
                HttpSession session = request.getSession(false);
                MemberDto loginUser = (session != null) ? (MemberDto) session.getAttribute("loginUser") : null;
                if (loginUser != null && "ADMIN".equals(loginUser.getMemberStatus())) {
                    int inquiryId = Integer.parseInt(request.getParameter("inquiryId"));
                    String answerContent = request.getParameter("answerContent");
                    
                    BoardService.getInstance().answerInquiry(inquiryId, answerContent);
                }
                isRedirect = true;
                viewPage = contextPath + "/member/mypage.do";
                
            } else if (command.equals("/board/reviewAction.do")) {
                HttpSession session = request.getSession(false);
                MemberDto loginUser = (session != null) ? (MemberDto) session.getAttribute("loginUser") : null;
                if (loginUser == null) {
                    isRedirect = true;
                    viewPage = contextPath + "/member/login.do";
                } else {
                    int bikeId = Integer.parseInt(request.getParameter("bikeId"));
                    int reservationId = Integer.parseInt(request.getParameter("reservationId"));
                    int rating = Integer.parseInt(request.getParameter("rating"));
                    String title = request.getParameter("title");
                    String content = request.getParameter("content");
                    
                    ReviewDto dto = new ReviewDto();
                    dto.setUserId(loginUser.getMemberId());
                    dto.setReservationId(reservationId);
                    dto.setBikeId(bikeId);
                    dto.setRating(rating);
                    dto.setTitle(title);
                    dto.setContent(content);
                    
                    BoardService.getInstance().submitReview(dto);
                    
                    isRedirect = true;
                    viewPage = contextPath + "/bike/bikeDetail.do?bikeId=" + bikeId;
                }
            } else {
                response.sendError(HttpServletResponse.SC_NOT_FOUND);
                return;
            }
            
        } catch (Exception e) {
            e.printStackTrace();
            throw new ServletException(e);
        }

        if (viewPage != null) {
            if (isRedirect) {
                response.sendRedirect(viewPage);
            } else {
                request.getRequestDispatcher(viewPage).forward(request, response);
            }
        }
    }
}
