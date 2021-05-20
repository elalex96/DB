USE [Adinco]
GO


IF EXISTS
(
    SELECT 1
    FROM dbo.sysobjects
    WHERE name = 'SP_EN_ArmadoHTMLTablaPresupuesto'
)
    DROP PROCEDURE SP_EN_ArmadoHTMLTablaPresupuesto;
GO 

/****** Object:  StoredProcedure [dbo].[SP_EN_ArmadoLineaDelTiempoPerforacion]    Script Date: 19/05/2021 11:10:23 a. m. ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
-- =============================================
-- Author: Daniel Ac
-- Create date: 19-05-21
-- Description: Se agrego tabla fija de presupuesto
-- =============================================
CREATE PROCEDURE [dbo].[SP_EN_ArmadoHTMLTablaPresupuesto] --3,10019
@IdContrato INT, 
@IdUsuario  INT 
AS
BEGIN
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

	SET @HTML=N'<style type="text/css">
					.tg  {border-collapse:collapse;border-spacing:0;}
					.tg td{border-color:black;border-style:solid;border-width:1px;font-family:Arial, sans-serif;font-size:14px;
					  overflow:hidden;padding:10px 5px;word-break:normal;}
					.tg th{border-color:black;border-style:solid;border-width:1px;font-family:Arial, sans-serif;font-size:14px;
					  font-weight:normal;overflow:hidden;padding:10px 5px;word-break:normal;}
					.tg .tg-c3ow{border-color:inherit;text-align:center;vertical-align:top}
					.tg .tg-0pky{border-color:inherit;text-align:left;vertical-align:top}
					.tg .tg-dvpl{border-color:inherit;text-align:right;vertical-align:top}
					</style>
			      <table class="tg" width="100%">
					<thead>
					  <tr>
						<th class="tg-0pky" rowspan="2">Sub-Actividad</th>
						<th class="tg-c3ow" colspan="2">Alternativa 1</th>
						<th class="tg-c3ow" colspan="2">Alternativa 2</th>
					  </tr>
					  <tr>
						<td class="tg-0pky">Base</td>
						<td class="tg-0pky">Contingente</td>
						<td class="tg-0pky">Base</td>
						<td class="tg-0pky">Contingente</td>
					  </tr>
					</thead>
					<tbody>
					  <tr>
						<td class="tg-0pky">General</td>
						<td class="tg-dvpl">$4,000,000</td>
						<td class="tg-dvpl">$4,000,000.00</td>
						<td class="tg-dvpl">$4,000,000.00 </td>
						<td class="tg-dvpl">$4,000,000.00</td>
					  </tr>
					  <tr>
						<td class="tg-0pky">GeoGeofísica</td>
						<td class="tg-dvpl">$144,000.00</td>
						<td class="tg-dvpl">$624,000.00</td>
						<td class="tg-dvpl">$144,000.00</td>
						<td class="tg-dvpl">$624,000.00</td>
					  </tr>
					  <tr>
						<td class="tg-0pky">Geología</td>
						<td class="tg-dvpl">$2,088,000.00 </td>
						<td class="tg-dvpl">$2,088,000.00 </td>
						<td class="tg-dvpl">$2,088,000.00 </td>
						<td class="tg-dvpl">$2,088,000.00</td>
					  </tr>
					  <tr>
						<td class="tg-0pky">Perforación de Pozos</td>
						<td class="tg-dvpl">$42,400,003.00</td>
						<td class="tg-dvpl">$43,000,003.00</td>
						<td class="tg-dvpl">$28,736,000.00</td>
						<td class="tg-dvpl">$29,336,000.00</td>
					  </tr>
					  <tr>
						<td class="tg-0pky">Ingenieria de Yacimientos</td>
						<td class="tg-dvpl">$100,000.00</td>
						<td class="tg-dvpl">$600,000.00</td>
						<td class="tg-dvpl">$100,000.00</td>
						<td class="tg-dvpl">$600,000.00</td>
					  </tr>
					  <tr>
						<td class="tg-0pky">Seguridad, Salud y Medio Ambiente</td>
						<td class="tg-dvpl">$179,800.00</td>
						<td class="tg-dvpl">$179,800.00</td>
						<td class="tg-dvpl">$179,800.00</td>
						<td class="tg-dvpl">$179,800.00</td>
					  </tr>
					   <tr>
						<td class="tg-dvpl">Total</td>
						<td class="tg-dvpl">$48,911,803.00</td>
						<td class="tg-dvpl">$50,491,803.00</td>
						<td class="tg-dvpl">$35,247,800.00</td>
						<td class="tg-dvpl">$36,827,800.00</td>
					  </tr>
					</tbody>
					</table>'

	SELECT @HTML AS HtmlArmado



END;
