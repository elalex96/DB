-- =============================================
-- Author:		Reyna Olvera
-- Create date: 22/0372018
-- Description:	Comprueba que este agregada la cromatografia para realizar el calculo SIPAC
-- =============================================
CREATE PROCEDURE [dbo].[CO_VerificaCromatografiaAgregada]
	-- Add the parameters for the stored procedure here
	@idContrato int,
	@puntoEntrega int,
	@fechaMesDiaAnio date
AS
BEGIN
--Exec CO_VerificaCromatografiaAgregada 3,1014,'2018-03-01'
	-- SET NOCOUNT ON added to prevent extra result sets from
	-- interfering with SELECT statements.
	SET NOCOUNT ON;

    -- Insert statements for procedure here
	
 Declare @puntoEntregaContratoId int;
 Select @puntoEntregaContratoId= PuntoEntregaContratoID 
 From [CO_PuntosdeEntregaContrato]
 where PuntoEntregaID=@puntoEntrega and idContrato=@idContrato

 Select Count(idCromatografiaValor) 
 From CO_Cromatografia C
 JOIN CO_CromatografiaValores CV on C.idCromatografia =CV.idCromatografia
 JOIN [CO_PuntosdeEntregaContrato] PEC on CV.idPuntoEntregacontrato=PEC.PuntoEntregaContratoID
 where c.idContrato=@idContrato AND MES=MONTH(@fechaMesDiaAnio) AND Anio=YEAR(@fechaMesDiaAnio)
 AND CV.idPuntoEntregacontrato=@puntoEntregaContratoId;
END
