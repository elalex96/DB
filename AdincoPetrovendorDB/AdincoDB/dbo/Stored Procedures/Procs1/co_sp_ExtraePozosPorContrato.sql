CREATE PROCEDURE [dbo].[co_sp_ExtraePozosPorContrato]--1,10038
    @IdUsuario INT,
    @IdContrato INT
AS
BEGIN
		SELECT 
			IdInstalacion,NombreInstalacion,IdInstalacionPemex
		FROM
			CO_CONTRATO	C 
		JOIN
			CO_INSTALACION	I (NOLOCK)  
			ON	C.IdContrato = @IdContrato
			AND
				C.IdAreaContractual	=	I.IdAreaContractual
		WHERE 
			C.IdContrato = @IdContrato
END;