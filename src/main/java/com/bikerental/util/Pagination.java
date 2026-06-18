package com.bikerental.util;

public class Pagination {
    private int pageSize = 10; // 한 페이지당 게시글 수
    private int blockSize = 5;  // 한 블록당 페이지 수
    
    private int currentPage;    // 현재 페이지
    private int totalItems;     // 전체 게시글 수
    
    private int totalPages;     // 전체 페이지 수
    private int startPage;      // 블록의 시작 페이지
    private int endPage;        // 블록의 끝 페이지
    
    private int startRow;       // DB에서 가져올 시작 행 번호
    private int endRow;         // DB에서 가져올 끝 행 번호

    public Pagination(int totalItems, int currentPage) {
        this.totalItems = totalItems;
        this.currentPage = currentPage;
        
        // 전체 페이지 수 계산
        totalPages = (int) Math.ceil((double) totalItems / pageSize);
        
        // 블록의 시작 페이지와 끝 페이지 계산
        startPage = ((currentPage - 1) / blockSize) * blockSize + 1;
        endPage = startPage + blockSize - 1;
        
        // 끝 페이지가 전체 페이지 수보다 크면 전체 페이지 수로 맞춤
        if (endPage > totalPages) {
            endPage = totalPages;
        }
        
        // DB에서 가져올 시작 행과 끝 행 번호 계산
        startRow = (currentPage - 1) * pageSize + 1;
        endRow = startRow + pageSize - 1;
    }

    public Pagination(int totalItems, int currentPage, int pageSize, int blockSize) {
        this.totalItems = totalItems;
        this.currentPage = currentPage;
        this.pageSize = pageSize;
        this.blockSize = blockSize;
        
        totalPages = (int) Math.ceil((double) totalItems / pageSize);
        startPage = ((currentPage - 1) / blockSize) * blockSize + 1;
        endPage = startPage + blockSize - 1;
        if (endPage > totalPages) {
            endPage = totalPages;
        }
        startRow = (currentPage - 1) * pageSize + 1;
        endRow = startRow + pageSize - 1;
    }

    // Getters
    public int getPageSize() { return pageSize; }
    public int getBlockSize() { return blockSize; }
    public int getCurrentPage() { return currentPage; }
    public int getTotalItems() { return totalItems; }
    public int getTotalPages() { return totalPages; }
    public int getStartPage() { return startPage; }
    public int getEndPage() { return endPage; }
    public int getStartRow() { return startRow; }
    public int getEndRow() { return endRow; }
}
