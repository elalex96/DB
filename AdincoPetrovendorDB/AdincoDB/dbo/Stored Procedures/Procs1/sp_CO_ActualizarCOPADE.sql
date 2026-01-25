IF EXISTS
    (
        SELECT
            1
        FROM
            dbo.sysobjects
        WHERE
            name = 'sp_CO_ActualizarCOPADE'
    )
    DROP PROCEDURE sp_CO_ActualizarCOPADE;
GO
Create Proc sp_CO_ActualizarCOPADE
@pIdCopade int,
@pIdContrato  int,
@pNumeroCOPADE int,
@pFechaEmision datetime,
@pArchivo  nvarchar(510),
@IdUsuario INT,
@Activo bit,
@DocumentoId INT

As
BEGIN

    DECLARE @AntesNumeroCOPADE INT,@AntesFechaEmision DATETIME,@AntesArchivo  VARCHAR(510),@AntesActivo BIT,@AntesDocumentoId INT;

    SELECT 
    @AntesNumeroCOPADE  =  NumeroCOPADE ,
    @AntesFechaEmision  =  FechaEmision,
    @AntesArchivo   =   Archivo,
    @AntesActivo    =   Activo,
    @AntesDocumentoId   =   DocumentoId
    FROM 
        CO_COPADE (NOLOCK)
    WHERE 
        IdCopade = @pIdCopade;

	UPDATE CO_COPADE
	SET NumeroCOPADE = @pNumeroCOPADE,
		FechaEmision = @pFechaEmision,
        ModificadoPor = @IdUsuario,
        ModificadoEn = GETDATE(),
        Activo = @Activo ,
        DocumentoId = 
        CASE 
            WHEN @DocumentoId > 0
        THEN 
            @DocumentoId
        ELSE DocumentoId
        END,
        Archivo = 
        CASE 
            WHEN @DocumentoId > 0
        THEN 
            @pArchivo
        ELSE Archivo
        END
	WHERE IdCopade = @pIdCopade;

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
			,'Edición'
			,'Edición de COPADE en la página 2/CIEP/RegistroCOPADE.aspx'
            ,'IdCopade:  ['+CAST(@pIdCopade AS VARCHAR(20))+
            '],NumeroCOPADE Nuevo: [' + CAST(@pNumeroCOPADE AS VARCHAR(20)) +  '], NumeroCOPADE Antes: [' + CAST(@AntesNumeroCOPADE AS VARCHAR(20)) + 
            '],FechaEmision Nuevo: [' + CONVERT(VARCHAR(19), @pFechaEmision, 120) +   '], FechaEmision Antes: ['  + CONVERT(VARCHAR(19), @AntesFechaEmision, 120) + 
            '],Activo Nuevo: [' + CASE WHEN @Activo = 1 THEN 'SI' ELSE 'NO' END +   '], Activo Antes: ['  +CASE WHEN @AntesActivo = 1 THEN 'SI' ELSE 'NO' END 
            +CASE 
                WHEN    @DocumentoId    >   0
                THEN
                '],DocumentoId Nuevo: [' + CAST(@DocumentoId AS VARCHAR(20))+  
                '], DocumentoId Antes: ['  + CAST(@AntesDocumentoId AS VARCHAR(20)) +'].'
            ELSE
                ']'
            END
			,@IdUsuario
			,@pIdContrato);
END
