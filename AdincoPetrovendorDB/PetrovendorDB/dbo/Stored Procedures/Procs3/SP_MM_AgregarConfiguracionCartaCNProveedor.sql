USE [Petrovendor]
GO
-- Evaluamos si el SP existe; si es así, lo eliminamos.
DROP PROCEDURE IF EXISTS [dbo].[SP_MM_AgregarConfiguracionCartaCNProveedor];
GO
-- =============================================
-- Author:		Alexander Gomez
-- Create date: 24/04/2026
-- Description:	Inserta una nueva configuración de Carta de Contenido
--              Nacional (Proveedor a Proveedor) en la tabla
--              PV_ConfiguracionProveedoresOperadoras.
--              Agrega los parámetros @CreadoPor y @CreadoEl para
--              registrar el usuario de sesión y la fecha de creación.
-- =============================================
CREATE PROCEDURE [dbo].[SP_MM_AgregarConfiguracionCartaCNProveedor]
    @IdContrato  INT,
    @CreadoPor   INT      = NULL,
    @CreadoEl    DATETIME = NULL
AS
BEGIN
    SET NOCOUNT ON;

    INSERT INTO dbo.PV_ConfiguracionProveedoresOperadoras
        (IdContrato, Activo, CreadoPor, CreadoEl)
    VALUES
        (@IdContrato, 1, @CreadoPor, ISNULL(@CreadoEl, GETDATE()));

END