-- =============================================
-- Author:		Daniel Cruz
-- Create date: 12-12-17
-- Description:	
-- =============================================
-- =============================================
-- Author:		Daniel Cruz
-- Create date: 04/01/12
-- Description:	Actualice referencia a imagen 
-- =============================================
CREATE PROCEDURE [dbo].[SP_CD_MembreteEmpresaFormatoOCD]
    -- Add the parameters for the stored procedure here
    @IdFactura INT
AS
BEGIN
    -- SET NOCOUNT ON added to prevent extra result sets from
    -- interfering with SELECT statements.
    SET NOCOUNT ON;

    -- Insert statements for procedure here


    DECLARE @sinImagen INT;
    SET @sinImagen =
    (
        SELECT COUNT(IdImagen)
        FROM S_ImagenPerfil IP
            INNER JOIN dbo.S_Proveedor PV
                ON PV.IdProveedor = IP.IdProveedor
            INNER JOIN dbo.FI_Factura F
                ON F.Emisor = PV.RFC
        WHERE F.IdFactura = @IdFactura
    );

    IF (@sinImagen > 0)
    BEGIN
        SELECT IP.ImagenProveedor
        FROM S_ImagenPerfil IP
            INNER JOIN dbo.S_Proveedor PV
                ON PV.IdProveedor = IP.IdProveedor
            INNER JOIN dbo.FI_Factura F
                ON F.Emisor = PV.RFC
        WHERE F.IdFactura = @IdFactura;
    END;
    
END;
