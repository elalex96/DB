IF EXISTS
    (
        SELECT
            1
        FROM
            dbo.sysobjects
        WHERE
            name = 'sp_CO_InsertarCOPADE'
    )
    DROP PROCEDURE sp_CO_InsertarCOPADE;
GO
CREATE PROCEDURE sp_CO_InsertarCOPADE
@pIdCopade	int,
@pIdContrato	int,
@pNumeroCOPADE	int,
@pFechaEmision	date,
@pArchivo	nvarchar(510),
@IdUsuario INT,
@Activo bit,
@DocumentoId INT
AS
BEGIN
DECLARE @IdCopade INT  = 0;

	INSERT INTO CO_COPADE(
		IdContrato,NumeroCOPADE,FechaEmision,Archivo,
        CreadoPor,CreadoEn,Activo, DocumentoId
	)
	VALUES(
	@pIdContrato,@pNumeroCOPADE,@pFechaEmision,@pArchivo,
    @IdUsuario,GETDATE(), @Activo, @DocumentoId);

	set @IdCopade = SCOPE_IDENTITY() 

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
			,'Creación'
			,'Creación de COPADE en la página 2/CIEP/RegistroCOPADE.aspx'
			,'IdCopade:  ['+CAST(@IdCopade AS VARCHAR(20))+'], NumeroCOPADE: [' + CAST(@pNumeroCOPADE AS VARCHAR(20)) + 
			'], FechaEmision: [' + CONVERT(VARCHAR(19), @pFechaEmision, 120) + 
			'], Activo: ['+CASE
			WHEN @Activo = 1
			THEN 'SI'
			ELSE 'NO'
			END +'], DocumentoId: ['+CAST(@DocumentoId AS VARCHAR(20))+'].'
			,@IdUsuario
			,@pIdContrato
			);
END


