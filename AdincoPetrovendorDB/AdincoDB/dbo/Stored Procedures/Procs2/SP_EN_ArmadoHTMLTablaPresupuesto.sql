CREATE PROCEDURE [dbo].[SP_EN_ArmadoHTMLTablaPresupuesto] --3,10019
@IdContrato INT, 
@IdUsuario  INT 
AS
BEGIN
-- =============================================
-- Author: Daniel Ac
-- Create date: 19-05-21
-- Description: Se agrego tabla fija de presupuesto
-- =============================================

    SET NOCOUNT ON;
	SET language Spanish;
	--/*
--10049	CNH-R02-L01-A10.CS/2017		A10
--10050	CNH-R03-L01-G-CS-01/2018	A28
--10054	CNH-R01-L02-A1/2015			A1
--10055	CNH-R02-L01-A7.CS/2017		A7
--10056	CNH-R02-L01-A14.CS/2017		A14
--10057	CNH-R02-L04-AP-CS-G05/2018	A24
--REFERENCIA CON ESTE SP SP_ENI_PresupuestoTmp
--*/

    --ESTE CONFIGURACIÓN ES ESTATICA PARA TABLA DE EJEMPLO DE PENALIZACIONES
	DECLARE @HTML VARCHAR(MAX)=''

		SELECT @HTML=''
	
	SELECT @HTML AS HtmlArmado

END;