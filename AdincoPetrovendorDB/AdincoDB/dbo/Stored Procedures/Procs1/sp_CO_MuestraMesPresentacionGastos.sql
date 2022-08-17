-- =============================================
-- Author:	Reyna Olvera
-- Create date: 20190108
-- Description:	<Description,,>
-- =============================================
-- Modificado Por:	Neri Garcia
-- Fecha:			17 de Agosto del 2022
-- Descripción:		Agregado de (NOLOCK)
-- =============================================
CREATE PROCEDURE [dbo].[sp_CO_MuestraMesPresentacionGastos] 
    @IdContrato INT,
    @IdUsuario INT,
    @IdRegistro INT
AS
BEGIN
    SET NOCOUNT ON;
    SET LANGUAGE Spanish;
    /**/
    IF (@IdRegistro <> 0)
    BEGIN
        SELECT 1 AS registrado,
               CO_Registro.MesPresentacion,
               'Este gasto se encuentra guardado con el periodo reporte de '
               + DATENAME(MONTH, CO_Registro.MesPresentacion) + '-'
               + CONVERT(VARCHAR(4), YEAR(CO_Registro.MesPresentacion)) AS titulo
        FROM CO_Registro (NOLOCK)
        WHERE CO_Registro.IdRegistro = @IdRegistro;
    END;
	/**/
    ELSE
    BEGIN
        SELECT 0 AS registrado,
               CO_Contrato.MesPresentacionCGI,
               'Este gasto será guardado con el periodo reporte de ' + DATENAME(MONTH, CO_Contrato.MesPresentacionCGI)
               + '-' + CONVERT(VARCHAR(4), YEAR(CO_Contrato.MesPresentacionCGI)) AS titulo
        FROM CO_Contrato (NOLOCK)
        WHERE CO_Contrato.IdContrato = @IdContrato;
    END;
END;