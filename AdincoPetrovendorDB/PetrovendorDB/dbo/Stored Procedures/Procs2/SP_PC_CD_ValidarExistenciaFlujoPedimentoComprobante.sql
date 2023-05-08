-- =============================================
-- Author:	Daniel Cruz
-- Create date: 27-03-18
-- Description:	CONSULTAR SI EL PROVEEDOR ES EXTRANJERO Y SI YA EXISTEN FLUJOS PARA PEDIMENTOS O COMPROBANTES
-- =============================================
CREATE PROCEDURE [dbo].[SP_PC_CD_ValidarExistenciaFlujoPedimentoComprobante] 
    -- Add the parameters for the stored procedure here
    @IdProveedor INT,   
    @IdContrato INT
AS
BEGIN
    -- SET NOCOUNT ON added to prevent extra result sets from
    -- interfering with SELECT statements.
    SET NOCOUNT ON;

    -- Insert statements for procedure here
    DECLARE @EXISTE_FLUJO_ACTIVO_PREDETERMINADO INT = 0;
    DECLARE @EXISTE_FLUJO NVARCHAR(50);
    DECLARE @Nacionalidad INT;
	DECLARE @NOMBRE_PROVEEDOR NVARCHAR(MAX) =''
    ---Validación de Estatus de documentos





        SET @EXISTE_FLUJO_ACTIVO_PREDETERMINADO =
        (
            SELECT COUNT(F.IdFlujoTarea)
            FROM dbo.TA_FlujoTarea F
            WHERE F.IdProveedor = @IdProveedor
                  AND F.Activo = 1
                  AND ISNULL(F.Eliminado, 0) = 0                 
                  AND F.IdTipoOperacion = 16  --->comprobante extranjero
        ); /*FLUJO DE PEDIMENTO O COMPROBANTE EXTRANJERO*/


		SELECT ISNULL(@EXISTE_FLUJO_ACTIVO_PREDETERMINADO,0)
        

    
END;
