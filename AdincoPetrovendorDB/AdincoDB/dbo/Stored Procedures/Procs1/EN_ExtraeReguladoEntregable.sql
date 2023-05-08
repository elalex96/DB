-- =============================================
-- Author:		Reyna Olvera
-- ALTER date: 28/05/2018
-- Description:	<Description,,>
-- =============================================--************************************************************************************************************************
create PROCEDURE [dbo].[EN_ExtraeReguladoEntregable]
	-- Add the parameters for the stored procedure here
	@idInstanciaentregable int,
	@idcontrato int
AS
BEGIN
--Exec EN_ExtraeReguladoEntregable 10000,3
	SET NOCOUNT ON;

	SET LANGUAGE Spanish;
    
	Select idRegulador, EE.idEntregable,DocumentoEntregable, idInstanciaEntregable,Concat( Day(FechasLimiteaprobacion),'-',DATENAME(MONTH, FechasLimiteaprobacion),'-', DATENAME(year, FechasLimiteaprobacion)) as Fecha
	from EN_Entregable EE
	Join EN_ContratoEntregable EC on EE.idEntregable=EC.idEntregable
	JOIN EN_instanciasEntregable IE on EC.idContratoEntregable=IE.idContratoEntregable
	where idInstanciaEntregable=@idInstanciaentregable and EC.idContrato=@idcontrato

END

