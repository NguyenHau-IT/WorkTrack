package com.example.worktrack.util;

import org.springframework.security.core.Authentication;
import org.springframework.security.core.GrantedAuthority;
import org.springframework.security.core.context.SecurityContextHolder;
import org.springframework.stereotype.Component;

import java.util.Collection;

/**
 * Utility class để kiểm tra quyền và vai trò của user
 */
@Component
public class RoleUtil {

    /**
     * Kiểm tra user hiện tại có phải admin không
     * 
     * @return true nếu user có role ADMIN
     */
    public static boolean isCurrentUserAdmin() {
        Authentication authentication = SecurityContextHolder.getContext().getAuthentication();
        if (authentication == null || !authentication.isAuthenticated()) {
            return false;
        }

        Collection<? extends GrantedAuthority> authorities = authentication.getAuthorities();
        return authorities.stream()
                .anyMatch(authority -> "ROLE_Admin".equalsIgnoreCase(authority.getAuthority()));
    }

    /**
     * Kiểm tra user hiện tại có role cụ thể không
     * 
     * @param roleName Tên role cần kiểm tra
     * @return true nếu user có role đó
     */
    public static boolean hasRole(String roleName) {
        Authentication authentication = SecurityContextHolder.getContext().getAuthentication();
        if (authentication == null || !authentication.isAuthenticated()) {
            return false;
        }

        Collection<? extends GrantedAuthority> authorities = authentication.getAuthorities();
        return authorities.stream()
                .anyMatch(authority -> ("ROLE_" + roleName).equalsIgnoreCase(authority.getAuthority()));
    }

    /**
     * Lấy username của user hiện tại
     * 
     * @return username hoặc null nếu chưa đăng nhập
     */
    public static String getCurrentUsername() {
        Authentication authentication = SecurityContextHolder.getContext().getAuthentication();
        if (authentication == null || !authentication.isAuthenticated()) {
            return null;
        }
        return authentication.getName();
    }

    /**
     * Kiểm tra user có quyền xem dữ liệu đã xóa mềm không
     * Hiện tại chỉ admin mới có quyền này
     * 
     * @return true nếu có quyền xem dữ liệu đã xóa mềm
     */
    public static boolean canViewSoftDeletedData() {
        return isCurrentUserAdmin();
    }
}