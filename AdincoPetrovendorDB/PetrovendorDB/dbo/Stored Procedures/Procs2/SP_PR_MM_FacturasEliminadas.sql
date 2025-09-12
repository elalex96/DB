USE [Petrovendor]
GO
IF OBJECT_ID('Petrovendor..SP_PR_MM_FacturasEliminadas') IS NOT NULL
BEGIN
DROP PROCEDURE SP_PR_MM_FacturasEliminadas;
END
GO
---------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------
-- =============================================
-- Author:      <Alexander Gomez>
-- Create date: <03-06-2019>
-- Description: <Consulta de facturas eliminadas>
-- =============================================
-- =============================================    
-- Author:           Alexaner Gomez   
-- Create date: 12/09/2025  
-- Description: se agrega filtro por fecha de carga de la aceptación de la factura
-- ============================================= 
CREATE PROCEDURE [dbo].[SP_PR_MM_FacturasEliminadas]
    -- Add the parameters for the stored procedure here
    @IdProveedor INT,
	@FechaInicio datetime,
	@FechaFin datetime 
AS
BEGIN
    -- SET NOCOUNT ON added to prevent extra result sets from
    -- interfering with SELECT statements.
    SET NOCOUNT ON;
    -- Insert statements for procedure here
    SELECT
        RE.IdProceso AS NoAceptacion,
        PR.RazonSocial AS Cliente,
        F.Receptor AS RFCCliente,
        F.UUID,
        F.Folio,
        F.Fecha AS FechaCarga,
        RE.FechaRegistro AS FechaEliminado,
        US.Nombre AS EliminadoPor,
        RE.ComentarioInterno AS Justificacion,
        F.IdFactura
    FROM dbo.AD_RegistroEliminacion AS RE
        LEFT JOIN dbo.PR_FI_Factura AS F 
            ON F.IdEliminacion = RE.IdEliminacion
        LEFT JOIN dbo.S_Proveedor AS PR 
            ON PR.RFC = F.Receptor-- AND PR.Activo = 1
        LEFT JOIN dbo.S_Usuario AS US
            ON US.IdUsuario = RE.IdUsuario
    WHERE 
        RE.IdProveedor = @IdProveedor
        AND 
		RE.TipoEliminacion = 'F'--Factura
		AND RE.FechaRegistro BETWEEN @FechaInicio AND @FechaFin
	ORDER BY F.CreadoEn DESC
END