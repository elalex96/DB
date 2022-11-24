-- =============================================  
-- Author:   Daniel AC  
-- Create date: 22/10/2020  
-- Description:  Validar si no existe un registro de Seguimiento del entregable instancia registrarlo 
-- ============================================= 
CREATE PROCEDURE [dbo].[SP_EN_CrearSeguimientoAvanceEntregable]
    @EntregableInstanciaId INT,
    @UsuarioId INT,
    @ContratoId INT
AS
BEGIN
    SET NOCOUNT ON;
    DECLARE @PorcentajeSinInicia VARCHAR(MAX);
    DECLARE @EntregableContratoId INT;
    DECLARE @AprobadoInternamente INT = 10003; --> ESTADO APROBADO INTERNAMENTE
	/*
	ESTE SP SE UTILIZA EN LOS SP´S SP_EN_GuardarAvanceEntregableSeguimiento, SP_EN_ConsultarAvanceEntregableSeguimiento	
	*/

    --VALIDAR SI EXISTE LA INSTANCIA SOLICITADA  
    IF NOT EXISTS
    (
        SELECT idInstanciaEntregable
        FROM dbo.EN_InstanciasEntregable
        WHERE idInstanciaEntregable = @EntregableInstanciaId
    )
    BEGIN
        RETURN;
    ---SI NO EXISTE DETENER EL GUARDADO
    END;

    --VALIDAR SI NO EXISTE REGISTRO DE AVANCE GENERAL REALIZAR EL REGISTRO
    IF NOT EXISTS
    (
        SELECT 1
        FROM dbo.EN_AvanceEntregableSeguimiento
        WHERE EntregableInstanciaId = @EntregableInstanciaId
              AND Activo = 1
    )
    BEGIN
        --NO SE ENCONTRO REGISTRO DE SEGUIMIENTO GENERAL REALIZAR REGISTRO
        INSERT INTO dbo.EN_AvanceEntregableSeguimiento
        (
            EntregableInstanciaId,
            Porcentaje,
            CreadoPor,
            CreadoEl,
            Activo,
            ContratoId
        )
        VALUES
        (   @EntregableInstanciaId, -- EntregableInstanciaId - int
            0.0,                    -- Porcentaje - float
            @UsuarioId,             -- CreadoPor - int
            GETDATE(),              -- CreadoEl - datetime		    
            1,                      -- Activo - bit
            @ContratoId             -- ContratoId - int
            );
    END;

    --VALIDAR SI NO EXISTEN REGISTROS DE SEGUIMIENTO DE USUARIOS PARA LA INSTANCIA CREAR REGISTROS 
    IF NOT EXISTS
    (
        SELECT 1
        FROM dbo.EN_AvanceEntregableSeguimientoUsuario
        WHERE EntregableInstanciaId = @EntregableInstanciaId
              AND Activo = 1
    )
    BEGIN
        --NO HAY REGISTROS DE SEGUIMIENTO POR USUARIOS, CREARLOS 

        --OBTENER NOMBRE DEL AVANCE SIN INICIAR
        SELECT @PorcentajeSinInicia = NombreClave
        FROM dbo.EN_PorcentajeProgresoOpciones
        WHERE Clave = 'SIN_INICIAR';

        --OBTENER ENTREGABLE CONTRATO ID DEL ENTREGABLE INSTANCIA
        SELECT @EntregableContratoId = IdContratoEntregable
        FROM dbo.EN_InstanciasEntregable
        WHERE idInstanciaEntregable = @EntregableInstanciaId;

        --NO HAY REGISTROS DE AVANCE DE LOS USUARIOS HACER EL REGISTRO DE INICIO 
        INSERT INTO dbo.EN_AvanceEntregableSeguimientoUsuario
        (
            EntregableInstanciaId,
            IdEstado,
            Porcentaje,
            UsuarioId,
            CreadoPor,
            CreadoEl,
            Activo,
            ContratoId,
            NombreAvance
        )
        SELECT @EntregableInstanciaId,
               E.EstadoID,
               0,
               U.UsuarioID,
               @UsuarioId,
               GETDATE(),
               1,
               @ContratoId,
               @PorcentajeSinInicia
        FROM EN_Actividad A
            JOIN AP_Usuario U
                ON A.idUsuario = U.UsuarioID
                   AND A.IdContratoEntregable = @EntregableContratoId
            JOIN EN_Estado E
                ON A.EstadoID = E.EstadoID
            JOIN EN_ContratoEntregable CE
                ON A.IdContratoEntregable = CE.IdContratoEntregable
            JOIN EN_Entregable EN
                ON CE.IdEntregable = EN.IdEntregable
        WHERE A.EstadoID <> @AprobadoInternamente --> ESTATUS Aprobado Internamente	
        GROUP BY E.EstadoID,
                 U.UsuarioID;

    END;


END;

