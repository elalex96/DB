
-- =============================================
-- Author:		Alexander Gomez
-- Create date: 12-09-2018
-- Description:	Guardado de los datos de Approved SES(Murphy)
-- =============================================
CREATE procedure [dbo].[SP_MPY_Ins_Approved_SES]
	-- Add the parameters for the stored procedure here
	@SESNumber NVARCHAR(MAX), 
	@SESLine NVARCHAR(MAX), 
	@POSAPNumber NVARCHAR(MAX), 
	@POLineNumber NVARCHAR(MAX), 
	@Quantity NVARCHAR(MAX), 
	@UnitPrice NVARCHAR(MAX), 
	@Currency NVARCHAR(MAX), 
	@UnitPricebyQuantity NVARCHAR(MAX), 
	@CostObject NVARCHAR(MAX), 
	@MaterialGroup1 NVARCHAR(MAX), 
	@MaterialgroupDesc2 NVARCHAR(MAX), 
	@IdAceptacionPedido INT--,
	--@UOM varchar(50)
AS
BEGIN
	-- SET NOCOUNT ON added to prevent extra result sets from
	-- interfering with SELECT statements.
	SET NOCOUNT ON;

	select @IdAceptacionPedido = IdAceptacionPedido
	from MPY_MM_AceptacionPedido
	where IdPedido = @POSAPNumber

	if not exists(
		select 1
		from MPY_Approved_SES
		where SESNumber = @SESNumber and
		SESLine = @SESLine and
		POSAPNumber = @POSAPNumber and
		POLineNumber = @POLineNumber
	)
	begin

    -- Insert statements for procedure here
		INSERT INTO dbo.MPY_Approved_SES
	(
	    SESNumber,
	    SESLine,
	    POSAPNumber,
	    POLineNumber,
	    Quantity,
	    UnitPrice,
	    Currency,
	    UnitPricePerQuantity,
	    AccountAssignment,
	    CostObject,
	    MaterialGroup,
	    MaterialgroupDesc2,
	    IdDocuemnto--,
		--UOM
	)
	VALUES
	(   @SESNumber, -- SESNumber - nvarchar(max)
	    @SESLine, -- SESLine - nvarchar(max)
	    @POSAPNumber, -- POSAPNumber - nvarchar(max)
	    @POLineNumber, -- POLineNumber - nvarchar(max)
	    @Quantity, -- Quantity - nvarchar(max)
	    @UnitPrice, -- UnitPrice - nvarchar(max)
	    @Currency, -- Currency - nvarchar(max)
	    @UnitPricebyQuantity, -- UnitPricePerQuantity - nvarchar(max)
	    '', -- AccountAssignment - nvarchar(max)
	    @CostObject, -- CostObject - nvarchar(max)
	    @MaterialGroup1, -- MaterialGroup - nvarchar(max)
	    @MaterialgroupDesc2, -- MaterialgroupDesc2 - nvarchar(max)
	    @IdAceptacionPedido--,    -- IdDocuemnto - int
		--@UOM
	    )

	End
	Else
	Begin
		update MPY_Approved_SES
		set IdDocuemnto =@IdAceptacionPedido,
			Quantity=@Quantity,
			UnitPrice=@UnitPrice,
			Currency=@Currency,
			UnitPricePerQuantity=@UnitPricebyQuantity,
			AccountAssignment='',
			CostObject=@CostObject,
			MaterialGroup=@MaterialGroup1,
			MaterialgroupDesc2 = @MaterialgroupDesc2--,
			--UOM=@UOM
		where SESNumber = @SESNumber and
		SESLine = @SESLine and
		POSAPNumber = @POSAPNumber and
		POLineNumber = @POLineNumber
	End
END

