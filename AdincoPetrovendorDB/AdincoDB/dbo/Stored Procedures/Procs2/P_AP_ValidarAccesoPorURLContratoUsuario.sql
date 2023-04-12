CREATE PROC [dbo].[P_AP_ValidarAccesoPorURLContratoUsuario]
    @UsuarioId INT,
    @ContratoId INT,
    @Url VARCHAR(500),
    @Permitir BIT OUT
AS
BEGIN
    SET @Permitir = 0;
	SET @Url = LEFT(@Url, CHARINDEX('.aspx', @Url) - 1)+'.aspx';
    IF (ISNULL(LTRIM(RTRIM(UPPER(@Url))), '') LIKE '%ERROR%')
    BEGIN
        SET @Permitir = 1;
    END;
	IF (ISNULL(LTRIM(RTRIM(UPPER(@Url))), '') LIKE '%LLAMAURL%')
    BEGIN
        SET @Permitir = 1;
    END;
    IF (ISNULL(LTRIM(RTRIM(UPPER(@Url))), '') LIKE '%DEFAULT%')
    BEGIN
        SET @Permitir = 1;
    END;
    IF @Permitir = 0
    BEGIN
        SELECT @Permitir = 1
        FROM AP_Usuario (NOLOCK)
            INNER JOIN AP_PerfilUsuario (NOLOCK)
                ON AP_Usuario.UsuarioID = AP_PerfilUsuario.UsuarioID
            INNER JOIN AP_Perfil (NOLOCK)
                ON AP_PerfilUsuario.PerfilID = AP_Perfil.IdPerfil
            INNER JOIN AP_MenuDPorRol (NOLOCK)
                ON AP_Perfil.IdRol = AP_MenuDPorRol.IdRol
            INNER JOIN AP_MenuD (NOLOCK)
                ON AP_MenuDPorRol.IdMenu = AP_MenuD.MenuId
        WHERE AP_Usuario.UsuarioID = @UsuarioId
              AND AP_MenuDPorRol.visible = 1
              AND IdContrato = @ContratoId
              AND ISNULL(LTRIM(RTRIM(UPPER(Url))), '') LIKE '%' + ISNULL(LTRIM(RTRIM(UPPER(@Url))), '') + '%';
    END;
    /*Revisar si es rol de tipo root*/
    IF @Permitir = 0
    BEGIN
        SELECT @Permitir = 1
        FROM AP_Rol (NOLOCK)
            INNER JOIN AP_perfil (NOLOCK)
                ON AP_Rol.IdRol = AP_perfil.IdRol
            INNER JOIN AP_PerfilUsuario (NOLOCK)
                ON AP_perfil.IdPerfil = AP_PerfilUsuario.PerfilID
        WHERE AP_PerfilUsuario.UsuarioID = @UsuarioId
			    AND AP_Rol.Rol = 'Root'
    END;
    SELECT  @Permitir;
END;
