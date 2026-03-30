USE [Petrovendor]
GO

IF OBJECT_ID('[dbo].[USP_UPD_US_DesactivarUsuarioPorCorreoRebotado]', 'P') IS NOT NULL
    DROP PROCEDURE [dbo].[USP_UPD_US_DesactivarUsuarioPorCorreoRebotado];
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
-- =============================================
-- Author:		Alexander Gomez
-- Create date: 24/03/2026
-- Description:
/*
 * Prop�sito:
 *   Busca una direcci�n de correo electr�nico en las tablas de usuarios de
 *   las diferentes aplicaciones de ADINCO:
 *     1. Petrovendor/Procura  ? [Petrovendor].[dbo].[S_Usuario]
 *                               bit�cora: [Petrovendor].[dbo].[AP_Bitacora]
 *     2. ADINCO / Entregables ? [Adinco].[dbo].[AP_Usuario]
 *                               bit�cora: [Adinco].[dbo].[AP_Bitacora]
 *        (ADINCO y Entregables comparten la misma base de datos [Adinco])
 *
 *   Si encuentra coincidencia, marca al usuario como inactivo y registra
 *   el movimiento en la bit�cora de la aplicaci�n correspondiente.
 *
 * Par�metros de entrada:
 *   @Correo       - Direcci�n de correo a desactivar.
 *   @CuentaOrigen - Cuenta de correo desde la que se detect� el rebote
 *                   (notificaciones@adinco.mx).
 *
 * Par�metros de salida:
 *   @Desactivado  - 1 si se desactiv� en alguna aplicaci�n, 0 en caso contrario.
 *   @Detalle      - Descripci�n del resultado de la operaci�n.
 */
-- =============================================
CREATE PROCEDURE USP_UPD_US_DesactivarUsuarioPorCorreoRebotado
	-- Add the parameters for the stored procedure here
	@Correo       NVARCHAR(200),
    @CuentaOrigen NVARCHAR(200),
    @Desactivado  BIT           OUTPUT,
    @Detalle      NVARCHAR(500) OUTPUT
AS
BEGIN
	SET NOCOUNT ON;

    SET @Desactivado = 0;
    SET @Detalle     = '';

    DECLARE @UsuarioId        INT           = NULL;
    DECLARE @NombreUsuario    NVARCHAR(200) = '';
    DECLARE @AplicacionNombre NVARCHAR(100) = '';
    DECLARE @CorreoUsuario    NVARCHAR(200) = '';
    -- =========================================================================
    -- 1. PETROVENDOR / PROCURA
    --    Tabla de usuarios : [Petrovendor].[dbo].[S_Usuario]
    --      � PK      : IdUsuario   (int IDENTITY)
    --      � Nombre  : Nombre      (nvarchar 100)
    --      � Correo  : Correo      (nvarchar 200)
    --      � Estado  : Activo      (bit: 1 = activo, 0 = inactivo)
    --
    --    Tabla de bit�cora: [Petrovendor].[dbo].[AP_Bitacora]
    --      � Fecha     (datetime)
    --      � Tipo      (varchar 1000)
    --      � Mensaje   (varchar 1000)
    --      � UsuarioId (int)
    -- =========================================================================
    SELECT TOP 1
        @UsuarioId        = IdUsuario,
        @NombreUsuario    = ISNULL(Nombre, ''),
        @AplicacionNombre = 'Petrovendor/Procura',
        @CorreoUsuario    = Correo
    FROM [Petrovendor].[dbo].[S_Usuario]
    WHERE LOWER(Correo) = LOWER(@Correo)
      AND Activo = 1
      AND ISNULL(IsEliminado, 0) = 0;

    IF @UsuarioId IS NOT NULL
    BEGIN
        -- Desactivar usuario
        UPDATE [Petrovendor].[dbo].[S_Usuario]
        SET    Activo = 0
        WHERE  IdUsuario = @UsuarioId;

        -- Registrar en bit�cora
        INSERT INTO [Petrovendor].[dbo].[AP_Bitacora]
            (Fecha, Tipo, Mensaje, Detalle, UsuarioId)
        VALUES
            (
                GETDATE(),
                'SERVER-MONITOR',
                'Desactivaci�n autom�tica de usuario',
                CONCAT('Desactivaci�n autom�tica del usuario ', LTRIM(RTRIM(@NombreUsuario)),' (' ,@CorreoUsuario,')',
                       ' por error en entrega de correo.', 'Cuenta Origen: ', @CuentaOrigen, ' - ', 'Detectado en:' , @AplicacionNombre),
                @UsuarioId
            );

        SET @Desactivado = 1;
        SET @Detalle = 'Desactivado en ' + @AplicacionNombre;
        RETURN;
    END

    -- =========================================================================
    -- 2. ADINCO / ENTREGABLES
    --    ADINCO y Entregables comparten la misma base de datos [Adinco].
    --    Tabla de usuarios : [Adinco].[dbo].[AP_Usuario]
    --      � PK      : UsuarioID   (int IDENTITY)
    --      � Nombre  : Nombre      (varchar max)
    --      � Correo  : Usuario     (varchar max) � campo de login/correo
    --      � Estado  : IsActivo    (bit: 1 = activo, 0 = inactivo)
    --      � Baja    : IsEliminado (bit)
    --
    --    Tabla de bit�cora: [Adinco].[dbo].[AP_Bitacora]
    --      � Fecha     (datetime)
    --      � Tipo      (varchar 100)
    --      � Mensaje   (varchar 2000)
    --      � UsuarioId (int)
    -- =========================================================================
    SET @UsuarioId = NULL;

    SELECT TOP 1
        @UsuarioId        = UsuarioID,
        @NombreUsuario    = ISNULL(Nombre, ''),
        @AplicacionNombre = 'ADINCO/Entregables',
        @CorreoUsuario    = Usuario
    FROM [Adinco].[dbo].[AP_Usuario]
    WHERE LOWER(Usuario) = LOWER(@Correo)
      AND IsActivo = 1
      AND ISNULL(IsEliminado, 0) = 0;

    IF @UsuarioId IS NOT NULL
    BEGIN
        -- Desactivar usuario
        UPDATE [Adinco].[dbo].[AP_Usuario]
        SET    IsActivo = 0
        WHERE  UsuarioID = @UsuarioId;

        -- Registrar en bit�cora
        INSERT INTO [Adinco].[dbo].[AP_Bitacora]
            (Fecha, Tipo, Mensaje,Detalle, UsuarioId)
        VALUES
            (
                GETDATE(),
                'SERVER-MONITOR',
                'Desactivaci�n autom�tica de usuario',
                CONCAT('Desactivaci�n autom�tica del usuario ', LTRIM(RTRIM(@NombreUsuario)),' (' ,@CorreoUsuario,')',
                       ' por error en entrega de correo.', 'Cuenta Origen: ', @CuentaOrigen, ' - ', 'Detectado en:' , @AplicacionNombre),
                @UsuarioId
            );

        SET @Desactivado = 1;
        SET @Detalle = 'Desactivado en ' + @AplicacionNombre;
        RETURN;
    END

    -- =========================================================================
    -- Correo no encontrado en ninguna aplicaci�n
    -- =========================================================================
    SET @Desactivado = 0;
    SET @Detalle = 'No se pudo desactivar (correo no encontrado en usuarios de aplicaciones)';

END
GO
