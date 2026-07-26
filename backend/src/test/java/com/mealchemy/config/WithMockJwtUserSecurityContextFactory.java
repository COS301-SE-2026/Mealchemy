package com.mealchemy.config;

import org.springframework.security.authentication.UsernamePasswordAuthenticationToken;
import org.springframework.security.core.authority.SimpleGrantedAuthority;
import org.springframework.security.core.context.SecurityContext;
import org.springframework.security.core.context.SecurityContextHolder;
import org.springframework.security.test.context.support.WithSecurityContextFactory;

import java.util.List;

public class WithMockJwtUserSecurityContextFactory implements WithSecurityContextFactory<WithMockJwtUser> {

    @Override
    public SecurityContext createSecurityContext(WithMockJwtUser annotation) {
        SecurityContext context = SecurityContextHolder.createEmptyContext();

        var authentication = new UsernamePasswordAuthenticationToken(
            annotation.userId(),
            null,
            List.of(new SimpleGrantedAuthority("ROLE_USER"))
        );

        context.setAuthentication(authentication);
        return context;
    }
}