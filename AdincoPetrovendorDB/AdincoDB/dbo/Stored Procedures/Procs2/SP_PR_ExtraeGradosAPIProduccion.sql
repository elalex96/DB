-- =============================================
-- Author:		Reyna Olvera
-- Create date: 26/03/2018
-- Description: Fue realizado este SP ya que si se realiza el Join junto con las otras tablas,
--y no estaba dada de alta la cromatografia, fallaba al momento de buscar los datos
-- =============================================
CREATE PROCEDURE [dbo].[SP_PR_ExtraeGradosAPIProduccion]
	-- Add the parameters for the stored procedure here
	@fechaMesDiaAnio date,
	@hidrocarburo int,
	@PuntoEntrega int,
	@idContrato int,
	@idUsuario int=0
AS
BEGIN
	-- SET NOCOUNT ON added to prevent extra result sets from
	-- interfering with SELECT statements.
	SET NOCOUNT ON;

    -- Insert statements for procedure here
	Declare @puntoEntregaContratoId int;
 Select @puntoEntregaContratoId= PuntoEntregaContratoID 
 From [CO_PuntosdeEntregaContrato]
 where PuntoEntregaID=@PuntoEntrega and idContrato=@Idcontrato;

    -- Insert statements for procedure here
	Select 
	--**Agregue condensado de otra tabla
	CASE WHEN  @hidrocarburo=1000 or  @hidrocarburo=1002 
			THEN 0
			ELSE CV.GradosAPI
			END 
			AS GradosAPI
--** Si es gas, los grados api seran cero
--******************************************
	 from  CO_Cromatografia C 
	JOIN CO_CromatografiaValores CV on C.idCromatografia =CV.idCromatografia
	JOIN [CO_PuntosdeEntregaContrato] PEC on CV.idPuntoEntregacontrato=PEC.PuntoEntregaContratoID

	 where
	 C.idContrato=@Idcontrato 
	 AND C.MES=MONTH(@fechaMesDiaAnio) AND C.Anio=YEAR(@fechaMesDiaAnio)
	 AND CV.idPuntoEntregacontrato=@puntoEntregaContratoId;
END