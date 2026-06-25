package com.bikerental.service;

import java.io.File;
import java.nio.file.Files;
import java.nio.file.Paths;
import java.nio.file.StandardCopyOption;
import java.util.HashMap;
import java.util.List;
import java.util.Map;
import com.bikerental.dao.BoardDao;
import com.bikerental.dao.CommentDao;
import com.bikerental.dao.InquiryDao;
import com.bikerental.dao.ReviewDao;
import com.bikerental.dto.BoardDto;
import com.bikerental.dto.CommentDto;
import com.bikerental.dto.InquiryDto;
import com.bikerental.dto.ReviewDto;
import com.bikerental.util.Pagination;

public class BoardService {
    private static BoardService instance = new BoardService();

    private BoardService() {}

    public static BoardService getInstance() {
        return instance;
    }

    public Map<String, Object> getBoardList(String boardType, String pageParam) {
        Map<String, Object> result = new HashMap<>();
        int currentPage = 1;
        if (pageParam != null && !pageParam.isEmpty()) {
            currentPage = Integer.parseInt(pageParam);
        }
        
        int totalItems = BoardDao.getInstance().getPostCount(boardType);
        Pagination paging = new Pagination(totalItems, currentPage);
        List<BoardDto> postList = BoardDao.getInstance().getPostList(boardType, paging.getStartRow(), paging.getEndRow());
        
        result.put("postList", postList);
        result.put("paging", paging);
        return result;
    }

    public Map<String, Object> getBoardDetail(int postId) {
        Map<String, Object> result = new HashMap<>();
        // 조회수 1 증가
        BoardDao.getInstance().updateViewCount(postId);
        
        BoardDto post = BoardDao.getInstance().getPost(postId);
        List<CommentDto> commentList = CommentDao.getInstance().getCommentList(postId);
        
        result.put("post", post);
        result.put("commentList", commentList);
        return result;
    }

    public BoardDto getPost(int postId) {
        return BoardDao.getInstance().getPost(postId);
    }

    public void writePost(BoardDto dto, jakarta.servlet.http.Part filePart, String deployDir, String srcDir) throws Exception {
        String imageFilename = null;
        if (filePart != null && filePart.getSize() > 0) {
            String originalName = filePart.getSubmittedFileName();
            String safeName = originalName != null ? originalName.replaceAll("[\\\\/:*?\"<>|\\s]", "_") : "file";
            imageFilename = "board_" + System.currentTimeMillis() + "_" + safeName;
            
            // 배포 폴더에 파일 저장
            File uploadDir = new File(deployDir);
            if (!uploadDir.exists()) {
                uploadDir.mkdirs();
            }
            String deployFilePath = deployDir + File.separator + imageFilename;
            filePart.write(deployFilePath);
            
            // 소스 폴더 경로에도 복사
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
        dto.setFilename(imageFilename);
        BoardDao.getInstance().insertPost(dto);
    }

    public void updatePost(int postId, String title, String content, boolean deleteExisting, jakarta.servlet.http.Part filePart, String deployDir, String srcDir) throws Exception {
        BoardDto existingPost = BoardDao.getInstance().getPost(postId);
        String filename = (existingPost != null) ? existingPost.getFilename() : null;
        
        boolean hasNewFile = filePart != null && filePart.getSize() > 0;
        
        if (deleteExisting || hasNewFile) {
            // 기존 파일 삭제
            if (filename != null && !filename.isEmpty()) {
                try {
                    File deployFile = new File(deployDir + File.separator + filename);
                    if (deployFile.exists()) {
                        deployFile.delete();
                    }
                    File srcFile = new File(srcDir + File.separator + filename);
                    if (srcFile.exists()) {
                        srcFile.delete();
                    }
                } catch (Exception e) {
                    e.printStackTrace();
                }
                filename = null;
            }
            
            // 새 파일 저장
            if (hasNewFile) {
                String originalName = filePart.getSubmittedFileName();
                String safeName = originalName != null ? originalName.replaceAll("[\\\\/:*?\"<>|\\s]", "_") : "file";
                filename = "board_" + System.currentTimeMillis() + "_" + safeName;
                
                File uploadDir = new File(deployDir);
                if (!uploadDir.exists()) {
                    uploadDir.mkdirs();
                }
                String deployFilePath = deployDir + File.separator + filename;
                filePart.write(deployFilePath);
                
                File srcUploadDir = new File(srcDir);
                if (!srcUploadDir.exists()) {
                    srcUploadDir.mkdirs();
                }
                try {
                    Files.copy(
                        Paths.get(deployFilePath),
                        Paths.get(srcDir + File.separator + filename),
                        StandardCopyOption.REPLACE_EXISTING
                    );
                } catch (Exception e) {
                    e.printStackTrace();
                }
            }
        }
        
        BoardDto dto = new BoardDto();
        dto.setPostId(postId);
        dto.setTitle(title);
        dto.setContent(content);
        dto.setFilename(filename);
        
        BoardDao.getInstance().updatePost(dto);
    }

    public void deletePost(int postId, String deployDir, String srcDir) {
        // 첨부파일 삭제
        try {
            BoardDto post = BoardDao.getInstance().getPost(postId);
            if (post != null && post.getFilename() != null && !post.getFilename().isEmpty()) {
                String filename = post.getFilename();
                File deployFile = new File(deployDir + File.separator + filename);
                if (deployFile.exists()) {
                    deployFile.delete();
                }
                File srcFile = new File(srcDir + File.separator + filename);
                if (srcFile.exists()) {
                    srcFile.delete();
                }
            }
        } catch (Exception e) {
            e.printStackTrace();
        }
        
        BoardDao.getInstance().deletePost(postId);
    }

    public void writeComment(CommentDto dto) {
        CommentDao.getInstance().insertComment(dto);
    }

    public void deleteComment(int commentId) {
        CommentDao.getInstance().deleteComment(commentId);
    }

    public void submitInquiry(InquiryDto dto) {
        InquiryDao.getInstance().insertInquiry(dto);
    }

    public void answerInquiry(int inquiryId, String answerContent) {
        InquiryDao.getInstance().updateAnswer(inquiryId, answerContent);
    }

    public void submitReview(ReviewDto dto) {
        ReviewDao.getInstance().insertReview(dto);
    }
}
