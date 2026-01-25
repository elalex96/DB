IF EXISTS
    (
        SELECT
            1
        FROM
            dbo.sysobjects
        WHERE
            name = 'sp_CO_EliminarCOPADE'
    )
    DROP PROCEDURE sp_CO_EliminarCOPADE;
GO
CREATE PROCEDURE sp_CO_EliminarCOPADE
@pIdCopade int,
@IdUsuario INT,
@IdContrato INT
AS
BEGIN

	UPDATE 
        CO_COPADE
    SET 
        Activo = 0,
        ModificadoPor = @IdUsuario,
        ModificadoEn = GETDATE()
	WHERE 
        IdCopade  =   @pIdCopade;

        INSERT INTO dbo.AP_Bitacora (
			Fecha
			,Tipo
			,Mensaje
			,Detalle
			,UsuarioId
			,ContratoId
			)
		VALUES (
			GETDATE()
			,'Desactivación'
			,'Desactivación de COPADE en la página 2/CIEP/COPADE.aspx'
			,'IdCopade: ['+CAST(@pIdCopade AS VARCHAR(20))+'].' 
			,@IdUsuario
			,@IdContrato
			);
END

