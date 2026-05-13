USE [Petrovendor]
GO
-- Evaluamos si el SP existe; si es así, lo eliminamos.
DROP PROCEDURE IF EXISTS [dbo].[DEA_SP_AdministrarSolicitudCNProveedorExtranjero];
GO
-- =============================================
-- Author:		Alexander Gomez
-- Create date: 25/04/2026
-- Description:	Administra (agrega o elimina) un permiso de CN para
--              proveedores extranjeros en la tabla
--              DEA_SolicitudCNProveedorExtranjero.
--              Se agrega el parámetro @UsuarioId para registrar:
--                - CreadoPor / CreadoEl al agregar (AGREGAR)
--                - ModificadoPor / ModificadoEl al eliminar (ELIMINAR)
-- =============================================
CREATE PROCEDURE [dbo].[DEA_SP_AdministrarSolicitudCNProveedorExtranjero]
    @ContratoId   INT,
    @ProveedorId  INT,
    @TipoConsulta NVARCHAR(20),
    @UsuarioId    INT = NULL
AS
BEGIN
    SET NOCOUNT ON;

    IF @TipoConsulta = 'AGREGAR'
    BEGIN
        INSERT INTO dbo.DEA_SolicitudCNProveedorExtranjero
            (IdContrato, IdProveedor, CreadoPor, CreadoEl)
        VALUES
            (@ContratoId, @ProveedorId, @UsuarioId, GETDATE());
    END
    ELSE IF @TipoConsulta = 'ELIMINAR'
    BEGIN
        UPDATE dbo.DEA_SolicitudCNProveedorExtranjero
        SET
            ModificadoPor = @UsuarioId,
            ModificadoEl  = GETDATE()
        WHERE IdContrato  = @ContratoId
          AND IdProveedor = @ProveedorId;

        DELETE FROM dbo.DEA_SolicitudCNProveedorExtranjero
        WHERE IdContrato  = @ContratoId
          AND IdProveedor = @ProveedorId;
    END

END
GO