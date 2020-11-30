
-- =============================================
-- Author:	Reyna Olvera
-- Create date: 23/03/18
-- Description: 
-- =============================================
CREATE PROCEDURE [dbo].[PR_ExtraeCromatografiaInsertadaMes]
	-- Add the parameters for the stored procedure here
	@puntoEntrega int,
	@idContrato int,
	@fechaMesDiaAnio date
AS
BEGIN
	-- SET NOCOUNT ON added to prevent extra result sets from
	-- interfering with SELECT statements.
	SET NOCOUNT ON;

    -- Insert statements for procedure here
	 Declare @puntoEntregaContratoId int;
 Select @puntoEntregaContratoId= PuntoEntregaContratoID 
 From [CO_PuntosdeEntregaContrato]
 where PuntoEntregaID=@puntoEntrega and idContrato=@idContrato;


 Select IdCromatografiaValor,C1,C2,C3,nC4,lC4,nC5,lC5,C6_plus,MOL_CO2,MOL_N2,MOL_h2S,PrecioPetroleo,PrecioCondensado,PrecioGas,GradosAPI,
 AguaSedimento,ViscosidadSSU,SalLBS_1000BLS,Azufre,PresionEntrega,cv.PrecioUnitarioDLS
 From CO_Cromatografia C
 JOIN CO_CromatografiaValores CV on C.idCromatografia =CV.idCromatografia
 JOIN [CO_PuntosdeEntregaContrato] PEC on CV.idPuntoEntregacontrato=PEC.PuntoEntregaContratoID
 where c.idContrato=@idContrato AND MES=MONTH(@fechaMesDiaAnio) AND Anio=YEAR(@fechaMesDiaAnio)
 AND CV.idPuntoEntregacontrato=@puntoEntregaContratoId;
 --Select * from CO_CromatografiaValores
END

