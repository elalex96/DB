-- =============================================
-- Author:		DANIEL AC
-- Create date: 28-03-18
-- Description:	actualizar pedimento
-- =============================================
CREATE PROCEDURE [dbo].[SP_PC_ActualizarPedimento]
    -- Add the parameters for the stored procedure here

    @IdProveedor INT,--
    @IdContrato INT,---
    @IdUsuario INT,---
    @IdPedimentoComprobante INT,---

	@NumeroPedimento NVARCHAR(MAX),--- 
	@ClavePedimento INT,---
	@FolioComprobante NVARCHAR(MAX),----
	@FechaPago DATE,----
	@Regimen NVARCHAR(MAX),---
	@AduanaES NVARCHAR(MAX),	----	
	@CvTipoDocFacturacion INT,---
	@AcuseElectronico NVARCHAR(max)

AS
BEGIN
    -- SET NOCOUNT ON added to prevent extra result sets from
    -- interfering with SELECT statements.
    SET NOCOUNT ON;

	IF DATEPART(YEAR,@FechaPago) = 1999 AND DATEPART(MONTH,@FechaPago)=01
	BEGIN 
		SET @FechaPago = NULL
	END 

	IF @ClavePedimento = 0 
	BEGIN 
		SET @ClavePedimento = NULL
	END 


	UPDATE FI_PedimentoComprobante
	SET   	
	NumeroPedimento=@NumeroPedimento, 
	ClavePedimento=@ClavePedimento,
	FolioComprobante=@FolioComprobante,	
	FechaPago=@FechaPago,
	Regimen=@Regimen,
	AduanaES=@AduanaES,	
	CvTipoDocFacturacion =@CvTipoDocFacturacion,
	AcuseElectronico=@AcuseElectronico,
	ModificadoPor = @IdUsuario,
	ModificadoEn =GETDATE()
	WHERE IdPedimentoComprobante=@IdPedimentoComprobante
	 
	SELECT 'UPDATE',@IdPedimentoComprobante
END;
