-- =============================================
-- Author: Daniel Ac
-- Create date: 19-05-2021
-- Description: Se agrego tabla para ejemplo de penalización
-- =============================================
CREATE PROCEDURE [dbo].[SP_EN_ArmadoDivEjemploPenalizaciones] --3,10019
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
--*/

    --ESTE CONFIGURACIÓN ES ESTATICA PARA TABLA DE EJEMPLO DE PENALIZACIONES
	DECLARE @HTML VARCHAR(MAX)=''

	SET @HTML=N'<h4><b>Ejemplo Período de Exploración y Evaluación:</b></h4>
                <br />
                <table class="egt">
                    <tr style="border-bottom: solid; border-color: black">
                        <th>Descripción</th>
                        <th>Monto</th>
                    </tr>
                    <tr>
                        <td>Monto Total Facturado del año:</td>
                        <td>$    15,000,000.00 </td>
                    </tr>
                    <tr>
                        <td>13% Contenido Nacional Comprometido:</td>
                        <td>$     1,950,000.00 </td>
                    </tr>
                    <tr>
                        <td>10% Contenido Nacional Real alcanzado:</td>
                        <td>$     1,500,000.00 </td>
                    </tr>
                    <tr style="border-bottom: solid; border-color: orange">
                        <td>Monto Incumplido de Contenido Nacional:</td>
                        <td>$       450,000.00 </td>
                    </tr>
                    <tr style="border-bottom: solid; border-color: red">
                        <td>15% Penalidad Sobre el Monto Incumplido:</td>
                        <td>$        67,500.00 </td>
                    </tr>
                </table>'

	SELECT @HTML AS HtmlArmado



END;