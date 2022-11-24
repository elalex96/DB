-- =============================================
-- Author:		Reynha Olvera
-- Create date: 20180906
-- Description:	<Description,,>
-- =============================================
CREATE PROCEDURE SP_VerificaDatosParaCalculoValores --'20180701',3,2
@MesReporte DATE,
@IdContrato INT,
@IdUsuario INT
AS
BEGIN
	SET NOCOUNT ON;
DECLARE @countG INT,
@CountP INT,
@CountDias INT,
@errorP nvarchar(Max)='';
			--SELECT * FROM SCOC_ReporteDiarioGas WHERE MesReporte=@mesReporte AND idContrato=@IdContrato;
			--SELECT * FROM SCOC_ReporteDiarioPetroleo WHERE MesReporte=@mesReporte AND idContrato=@IdContrato;

SELECT @CountG=COUNT(*) FROM SCOC_ReporteDiarioGas WHERE MesReporte=@mesReporte AND idContrato=@IdContrato;
SELECT @CountP=COUNT(*) FROM SCOC_ReporteDiarioPetroleo WHERE MesReporte=@mesReporte AND idContrato=@IdContrato;
SELECT @CountDias=COUNT(*) FROM dbo.AP_Calendario WHERE  PrimerDiaMes=@MesReporte;

IF(@countG<>@CountDias)
BEGIN

SET @errorP =@errorP+  'Faltan '+ CONVERT(NVARCHAR(max),@CountDias-@countG)+' días por capturar de gas,';
END
IF(@CountP<>@CountDias)
BEGIN
SET @errorP =@errorP+ 'Faltan '+CONVERT(NVARCHAR(max),@CountDias-@countP)+' días por capturar de Petroleo';
END

SELECT @errorP AS error

END
