-- =============================================
-- Author:	Reyna Olvera
-- Create date: 20190108
-- Description:	<Description,,>
-- =============================================
CREATE PROCEDURE sp_CO_MuestraMesPresentacionGastos-- 3,10061,1113
    @IdContrato INT,
    @IdUsuario INT,
    @IdRegistro INT
AS
BEGIN

    SET NOCOUNT ON;
	  SET LANGUAGE Spanish;
    IF (@IdRegistro <> 0)
    BEGIN
        SELECT 1 AS registrado,
               MesPresentacion,
			  'Este gasto se encuentra guardado con el periodo reporte de '  + DATENAME(MONTH, MesPresentacion)+ '-'
          + CONVERT(VARCHAR(4), YEAR(MesPresentacion)) AS titulo
        FROM dbo.CO_Registro
        WHERE IdRegistro = @IdRegistro;
    END;
    ELSE
    BEGIN
        SELECT 0 AS registrado,
               MesPresentacionCGI,
			   'Este gasto será guardado con el periodo reporte de '  +DATENAME(MONTH, MesPresentacionCGI) + '-'
          + CONVERT(VARCHAR(4), YEAR(MesPresentacionCGI)) AS titulo
        FROM dbo.CO_Contrato
        WHERE IdContrato = @IdContrato;
    END;

END;
