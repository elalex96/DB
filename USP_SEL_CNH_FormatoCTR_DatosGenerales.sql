
CREATE PROCEDURE [dbo].[USP_SEL_CNH_FormatoCTR_DatosGenerales] 
    @IdContrato          INT,
    @IdUsuario           INT,
    @MesInicio           DATE,
    @MesFin              DATE,
    @IdProgramaActividad INT
AS
BEGIN
	SELECT 
	CO_Contrato.NumeroContrato AS Contrato,
	CO_Contratista.NombreContratista AS Operador,
	'' AS FechaReporte,
	'' AS TipoContrato
	FROM 
		CO_Contrato
	JOIN
		CO_Contratista	
		ON	CO_Contrato.IdContratista	=	CO_Contratista.IdContratista
		WHERE CO_Contrato.IdContrato = @IdContrato;
END;
