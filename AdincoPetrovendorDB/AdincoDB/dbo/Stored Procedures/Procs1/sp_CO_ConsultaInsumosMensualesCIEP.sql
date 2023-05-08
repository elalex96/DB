-- =============================================
-- Author:		Miguel Gomez
-- Create date: 1-1-2016
-- Description:	Consulta los insumos mensuales
-- =============================================
CREATE PROCEDURE sp_CO_ConsultaInsumosMensualesCIEP 
	-- Add the parameters for the stored procedure here
	@IdContrato int = 0, 
	@Mes date 
AS
BEGIN
	-- SET NOCOUNT ON added to prevent extra result sets from
	-- interfering with SELECT statements.
	SET NOCOUNT ON;
	declare @wts as float
	declare @api as float
	declare @qce as float
	declare @gea as float
    -- Insert statements for procedure here
	SELECT  @wts =   Precio  from CO_PrecioMarcadorMensual
	where mes = @Mes and idcontrato = @IdContrato

	select @api = API,@qce = QCE from CO_ProduccionCrudoMensualCIEP
	where mes = @mes  and idcontrato = @IdContrato

	SELECT  @gea =  geaprobados   from CO_GEAceptadosMes
	where mes = @Mes and idcontrato = @IdContrato

	select @wts as wts, @api as api, @qce as qce, @gea as gea

END
