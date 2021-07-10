create proc p_CO_WDEA_Produccion_Diaria_INS_Bitacora
@Id INT,
@Error BIT,
@Alerta BIT,
@Observaciones varchar(max),
@ErrorOut varchar(250) OUT
as 
BEGIN

	BEGIN TRY

		UPDATE CO_WDEA_Produccion_Diaria
		SET ERROR = @ERROR,
			ALERTA = @ALERTA,
			Observaciones = @Observaciones
		WHERE Id = @Id
	END TRY
	BEGIN CATCH 
		SET @ErrorOut = ERROR_MESSAGE()
	END CATCH
END