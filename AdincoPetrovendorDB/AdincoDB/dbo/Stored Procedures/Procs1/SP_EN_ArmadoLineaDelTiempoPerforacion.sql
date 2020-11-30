-- =============================================
-- Author: Daniel Ac
-- Create date: 20-11-2020
-- Description: Se agrego linea de tiempo de perforación
-- =============================================
CREATE PROCEDURE [dbo].[SP_EN_ArmadoLineaDelTiempoPerforacion]
@IdContrato INT, 
@IdUsuario  INT 
AS
BEGIN
    SET NOCOUNT ON;
	SET language Spanish;
    --ESTE CONFIGURACIÓN ES ESTATICA PARA ARMADO DE PERFORACIÓN
	DECLARE @HTML VARCHAR(MAX)=''
	DECLARE @ETAIni	VARCHAR(500),
		@ETAFin VARCHAR(500),
		@NotificaPlanPlus1	VARCHAR(500),
		@Pozos	VARCHAR(250)

SELECT
	@ETAIni =	CASE WHEN @IdContrato = 10049	THEN 'Inicio 25 de Septiembre de 2017'	--A10
			WHEN @IdContrato = 10050	THEN 'Inicio 27 de Junio de 2018'		--A28
			WHEN @IdContrato = 10054	THEN 'Inicio 30 de Noviembre de 2015'		--A1
			WHEN @IdContrato = 10055	THEN 'Inicio 25 de Septiembre de 2017'	--A7
			WHEN @IdContrato = 10056	THEN 'Inicio 25 de Septiembre de 2017'	--A14
			WHEN @IdContrato = 10057	THEN 'Inicio 7 de Mayo de 2018'			--A24
		END,
	@ETAFin	= CASE WHEN @IdContrato = 10049	THEN 'Finaliza ' + LTRIM(DATEPART(DAY,dbo.FN_EN_SumaDiasHabiles('20170925', 120))) + ' de ' + DATENAME(MONTH,dbo.FN_EN_SumaDiasHabiles('20170925', 120)) + ' de ' + LTRIM(DATEPART(YEAR,dbo.FN_EN_SumaDiasHabiles('20170925', 120)))	--A10
			WHEN @IdContrato = 10050	THEN 'Finaliza ' + LTRIM(DATEPART(DAY,dbo.FN_EN_SumaDiasHabiles('20180627', 120))) + ' de ' + DATENAME(MONTH,dbo.FN_EN_SumaDiasHabiles('20180627', 120)) + ' de ' + LTRIM(DATEPART(YEAR,dbo.FN_EN_SumaDiasHabiles('20180627', 120)))	--A28
			WHEN @IdContrato = 10054	THEN 'Finaliza ' + LTRIM(DATEPART(DAY,dbo.FN_EN_SumaDiasHabiles('20151130', 90))) + ' de ' + DATENAME(MONTH,dbo.FN_EN_SumaDiasHabiles('20151130', 90)) + ' de ' + LTRIM(DATEPART(YEAR,dbo.FN_EN_SumaDiasHabiles('20151130', 90)))		--A1
			WHEN @IdContrato = 10055	THEN 'Finaliza ' + LTRIM(DATEPART(DAY,dbo.FN_EN_SumaDiasHabiles('20170925', 120))) + ' de ' + DATENAME(MONTH,dbo.FN_EN_SumaDiasHabiles('20170925', 120)) + ' de ' + LTRIM(DATEPART(YEAR,dbo.FN_EN_SumaDiasHabiles('20170925', 120)))	--A7
			WHEN @IdContrato = 10056	THEN 'Finaliza ' + LTRIM(DATEPART(DAY,dbo.FN_EN_SumaDiasHabiles('20170925', 180))) + ' de ' + DATENAME(MONTH,dbo.FN_EN_SumaDiasHabiles('20170925', 180)) + ' de ' + LTRIM(DATEPART(YEAR,dbo.FN_EN_SumaDiasHabiles('20170925', 180)))	--A14
			WHEN @IdContrato = 10057	THEN 'Finaliza ' + LTRIM(DATEPART(DAY,dbo.FN_EN_SumaDiasHabiles('20180507', 120))) + ' de ' + DATENAME(MONTH,dbo.FN_EN_SumaDiasHabiles('20180507', 120)) + ' de ' + LTRIM(DATEPART(YEAR,dbo.FN_EN_SumaDiasHabiles('20180507', 120)))	--A24
		END,
	@NotificaPlanPlus1 = CASE WHEN @IdContrato = 10049	THEN 'Inicio 10 de Octubre de 2018'	--A10
			WHEN @IdContrato = 10050	THEN 'Inicio 4 de Junio de 2019'		--A28
			WHEN @IdContrato = 10054	THEN 'Inicio 25 de Junio de 2016'		--A1
			WHEN @IdContrato = 10055	THEN 'Inicio 10 de Octubre de 2018'	--A7
			WHEN @IdContrato = 10056	THEN 'Inicio 10 de Octubre de 2018'	--A14
			WHEN @IdContrato = 10057	THEN 'Inicio 3 de Agosto de 2019'			--A24
		END,
	@Pozos	= CASE WHEN @IdContrato = 10049	THEN 'Sáasken-1EXP'	--A10
			WHEN @IdContrato = 10050	THEN 'NA'		--A28
			WHEN @IdContrato = 10054	THEN 'Amoca-2DEL, Amoca-3DEL, Amoca-4DEL, Tecoalli-2DEL, Miztón-2DEL, Miztón-3DES, Miztón-5DES, Miztón-7DES'		--A1
			WHEN @IdContrato = 10055	THEN 'Ehécatl-1EXP'	--A7
			WHEN @IdContrato = 10056	THEN 'NA'	--A14
			WHEN @IdContrato = 10057	THEN 'NA'			--A24
	END
/*
10049	CNH-R02-L01-A10.CS/2017		A10
10050	CNH-R03-L01-G-CS-01/2018	A28
10054	CNH-R01-L02-A1/2015			A1
10055	CNH-R02-L01-A7.CS/2017		A7
10056	CNH-R02-L01-A14.CS/2017		A14
10057	CNH-R02-L04-AP-CS-G05/2018	A24
*/

	SET @HTML=N'<br><div class="timeline-box timeline-horizontal" style="width: 2400px; height: 100px">
         <!-- Primer Periodo-->
        <div class="tl-row" style="width: 85px; height: 23px">
        </div>
        <div class="tl-row" style="width: 200px; height: 23px">
            <div class="tl-item">
                <div class="tl-bullet bg-blue"></div>
                <div class="tl-panel">' + LTRIM(@ETAIni) +
--                    Inicio 25 de Septiembre de 2017
                '</div>
            </div>
        </div>
        <div class="tl-row" style="width: 100px; height: 23px; text-align: center">
            <p style="color: #3498db"><strong>Etapa de Transición de Arranque</strong></p>
        </div>
        <div class="tl-row" style="width: 200px; height: 23px">
            <div class="tl-item">
                <div class="tl-bullet bg-blue"></div>
                <div class="tl-panel">' + LTRIM(@ETAFin) +
--                    Finaliza 20 de Marzo de 2018
                '</div>
            </div>
        </div>
         <!-- Segundo Periodo-->
        <div class="tl-row" style="width: 160px; height: 23px">
        </div>
        <div class="tl-row" style="width: 200px; height: 23px">
            <div class="tl-item">
                <div class="tl-bullet bg-purple"></div>
                <div class="tl-panel">' + LTRIM(@NotificaPlanPlus1) +
--                    Inicio 10 de Octubre de 2018
                '</div>
            </div>
        </div>
        <div class="tl-row" style="width: 200px; height: 23px; text-align: center">
            <p style="color: #7a3ecc"><strong>Periodo de Exploración</strong></p>
        </div>
        <div class="tl-row" style="width: 55px; height: 23px">
        </div>
        <div class="tl-row" style="width: 200px; height: 23px">
            <div class="tl-item">
                <div class="tl-bullet bg-green"></div>
                <div class="tl-panel">
                    Inicio 07 de Octubre de 2019
                </div>
            </div>
        </div>
        <!-- Tercer Periodo-->
        <div class="tl-row" style="width: 300px; height: 23px; text-align: center">
            <p style="color: #2ecc71"><strong>Perforación del Pozo ' + LTRIM(@Pozos) + '</strong></p>
        </div>
        <div class="tl-row" style="width: 200px; height: 23px">
            <div class="tl-item">
                <div class="tl-bullet bg-green"></div>
                <div class="tl-panel">
                    Finaliza 04 de Febrero de 2020
                </div>
            </div>
        </div>
        <div class="tl-row" style="width: 200px; height: 23px">
            <div class="tl-item">
                <div class="tl-bullet bg-purple"></div>
                <div class="tl-panel">
                    Finaliza 10 de Octubre de 2022
                </div>
            </div>
        </div>
    </div><br>'

	SELECT @HTML AS HtmlArmado
   

END;
