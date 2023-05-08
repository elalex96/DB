-- =============================================
-- Author:		JG
-- Create date: 15/05/2017
-- Description:	Actualiza el XML buscando el IdFactura por medio del UUID
-- =============================================
CREATE PROCEDURE SP_FI_ConsultaIDxUUID
	-- Add the parameters for the stored procedure here
	@UUID varchar(max),
	@XML  varchar(max)
AS
BEGIN
	-- SET NOCOUNT ON added to prevent extra result sets from
	-- interfering with SELECT statements.
	SET NOCOUNT ON;
	declare @IDFactura as int;
	declare @Response as varchar(max);
    -- Insert statements for procedure here
	set @IDFactura = (select IdFactura from FI_Factura where UUID = @UUID)
	if @IDFactura <= ''
		BEGIN
			update FI_Factura
				set XML = @XML 
				where IdFactura = @IDFactura
				set @Response = 'Succes'
		END	
	ELSE 
		BEGIN
				set @Response = 'Error'
		END
END
