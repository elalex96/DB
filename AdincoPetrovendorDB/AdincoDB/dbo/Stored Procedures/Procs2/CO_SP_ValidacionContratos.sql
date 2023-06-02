CREATE PROCEDURE [dbo].[CO_SP_ValidacionContratos]
	@NumeroContrato VARCHAR(300),
	@IdContratoRegistro INT,
	@IdContrato INT = 0,
	@IdUsuario INT = 0
	AS
    BEGIN
	 
	 IF((SELECT COUNT(1) FROM CO_Contrato WHERE REPLACE(NumeroContrato,' ','') = REPLACE(@NumeroContrato,' ','') AND IdContrato <> @IdContratoRegistro) > 0)
	 BEGIN
		SELECT 'Ya existe un registro con el mismo No. contrato'
	 END
		
	END