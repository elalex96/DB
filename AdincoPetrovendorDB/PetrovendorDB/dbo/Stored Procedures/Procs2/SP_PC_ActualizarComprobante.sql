-- =============================================
-- Author:      DANIEL AC
-- Create date: 28-03-18
-- Description: actualizar comprobante
-- =============================================
-- Author:      JOSE ROMAN
-- Create date: 04-07-2018
-- Description: Se agrega el guardado del Hash del comprobante
-- =============================================
CREATE PROCEDURE SP_PC_ActualizarComprobante
    -- Add the parameters for the stored procedure here
    @IdProveedor INT,
    @IdContrato INT,
    @IdUsuario INT,
    @IdPedimentoComprobante INT,
    @FolioComprobante NVARCHAR(MAX),
    @IdFormaPago INT,
    @FechaPago DATE,
    @IdMoneda INT,
    @CvTipoDocFacturacion INT, 
    @HashSHA256 NVARCHAR(300)
AS
BEGIN
    -- SET NOCOUNT ON added to prevent extra result sets from
    -- interfering with SELECT statements.
    SET NOCOUNT ON;

    IF DATEPART(YEAR,@FechaPago) = 1999 AND DATEPART(MONTH,@FechaPago)=1
    BEGIN 
        SET @FechaPago = NULL
    END 

    IF @IdFormaPago = 0 
    BEGIN 
        SET @IdFormaPago = NULL
    END 

    IF @IdMoneda = 0 
    BEGIN 
        SET @IdMoneda = NULL
    END 

    UPDATE FI_PedimentoComprobante
    SET FolioComprobante= @FolioComprobante,
        FechaPago = @FechaPago,
        IdFormaPago = @IdFormaPago,
        IdMoneda = @IdMoneda,   
        CvTipoDocFacturacion = @CvTipoDocFacturacion,
        ModificadoPor = @IdUsuario,
        ModificadoEn = GETDATE(),
        HashSHA256 = @HashSHA256
    WHERE IdPedimentoComprobante=@IdPedimentoComprobante
     
    SELECT 'UPDATE',@IdPedimentoComprobante
END;

