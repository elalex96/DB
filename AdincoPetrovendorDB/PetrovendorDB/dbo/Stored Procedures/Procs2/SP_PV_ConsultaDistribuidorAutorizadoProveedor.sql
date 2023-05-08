-- =============================================
-- Author:		DANIEL AC
-- Create date: 08/05/2018
-- Description:	ACTUALIZACIÓN DE REFERENCIAS DE S_DOCUMENTO A S_DOCUMENTO_S3
-- =============================================
CREATE PROCEDURE [dbo].[SP_PV_ConsultaDistribuidorAutorizadoProveedor]
    -- Add the parameters for the stored procedure here
    @idproveedor INT
AS
BEGIN
    -- SET NOCOUNT ON added to prevent extra result sets from
    -- interfering with SELECT statements.
    SET NOCOUNT ON;

    -- Insert statements for procedure here
    SELECT DA.IdDistribuidorAutorizado,
           DA.NombreEmpresa,
           DA.RFC,
           DA.FechaInicioDistribucion,
           DA.Descripcion,
           D.Documento,
           'Distribuidor Autorizado ' + NombreEmpresa + '.pdf' AS DistribuidorAutorizado
    FROM PV_DistribuidorAutorizado AS DA
        INNER JOIN S_Documento_S3 AS D
            ON D.IdDocumento = DA.IdDocumento
    WHERE DA.IdProveedor = @idproveedor
          AND DA.Activo = 1;
END;