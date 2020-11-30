
---------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------
-- =============================================
-- Author:      <Alexander Gomez>
-- Create date: <03-06-2019>
-- Description: <Consulta de facturas eliminadas>
-- =============================================
CREATE PROCEDURE [dbo].[SP_PR_MM_FacturasEliminadas]
    -- Add the parameters for the stored procedure here
    @IdProveedor INT
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
        AND RE.TipoEliminacion = 'F'--Factura
END