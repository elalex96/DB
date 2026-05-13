-- =============================================
-- Author:		DANIEL AC
-- Create date: 24-01-18
-- Description:	Insertar Documento para aprobación 
-- =============================================
CREATE PROCEDURE [dbo].[SP_MA_InsertarOperacion]
-- Add the parameters for the stored procedure here
@IdDocumento INT,
@IdFlujo INT,
@IdContrato INT,
@IdUsuarioRegistro INT,
@ComentarioGral NVARCHAR(MAX),
@FechaFinalizacion DATETIME,
@FechaFinalizacionActiva BIT,
@IdPrioridad INT,
@IdVigencia INT,
@IdFirma NVARCHAR(MAX),
@IdTipoDocumento INT,
@IdSubcontratista INT =0,
@FechaRegistro DATETIME= '25-01-2017 00:00'

AS
BEGIN
    SET NOCOUNT ON;
            
			DECLARE @IdTipoDocumentoF INT 

			IF @IdTipoDocumento = 0
				SET @IdTipoDocumentoF = NULL
			ELSE 
				SET @IdTipoDocumentoF = @IdTipoDocumento


			DECLARE @insertado INT 
			
			INSERT INTO dbo.MA_Operacion
			(
			    IdDocumento,
			    IdFlujo,
			    IdEstatusOperacion,
			    IdEstatusFlujo,
			    IdContrato,
			    IdUsuarioRegistro,
			    FechaRegistro,
			    ComentarioGral,			    
			    FechaFinalizacion,
			    IdPrioridad,
			    IdVigencia,
			    IsActivo,
			    IsEliminado,
			    IdFirma,			    
			    IdTipoDocumento,
				IsFechaFinalizacion
			)
			VALUES
			(   @IdDocumento,         -- IdDocumento - int
			    @IdFlujo,         -- IdFlujo - int
			    1,         -- IdEstatusOperacion - int
			    1,         -- IdEstatusFlujo - int
			    @IdContrato,         -- IdContrato - int
			    @IdUsuarioRegistro,         -- IdUsuarioRegistro - int
			    GETDATE(), -- FechaRegistro - datetime
			    @ComentarioGral,       -- ComentarioGral - nvarchar(max)
			    @FechaFinalizacion, -- FechaFinalizacion - datetime
			    @IdPrioridad,         -- IdPrioridad - int
			    @IdVigencia,         -- IdVigencia - int
			    1,         -- IsActivo - int
			    0,         -- IsEliminado - int
			    @IdFirma,       -- IdFirma - nvarchar(35)			    
			    @IdTipoDocumentoF,          -- IdTipoDocumento - int
				@FechaFinalizacionActiva
			    )

			SELECT @insertado = @@IDENTITY; 

			DECLARE @TIPO_OPERACION NVARCHAR(300)
			DECLARE @DescripcionH NVARCHAR(600)
		    (SELECT @TIPO_OPERACION= OT.Nombre 
			FROM dbo.MA_Flujo F
			INNER JOIN MA_TipoOperacion AS OT ON OT.IdTipoOperacion = F.IdTipoOperacion
			WHERE F.IdFlujo=@IdFlujo)
			
			SET @DescripcionH = 'Se ha registrado aprobación de ' ++ISNULL(@TIPO_OPERACION,'') + ' por '+(SELECT ISNULL(Nombre,'') FROM dbo.AP_Usuario WHERE UsuarioID =@IdUsuarioRegistro)

			INSERT INTO dbo.MA_HistorialOperacion
			(
			    IdOperacion,
			    Detalle,
			    Activo,
			    CreadoEl,
			    CreadoPor,
				IdEstadoFlujo
			)
			VALUES
			(   @insertado,         -- IdOperacion - int
			    @DescripcionH,       -- Detalle - nvarchar(max)
			    1,      -- Activo - bit
			    GETDATE(), -- CreadoEl - datetime
			    @IdUsuarioRegistro,         -- CreadoPor - int
				1 -- IdEstadoFlujo --> Tarea Iniciada
			    )
			            
			SELECT @insertado,'SUCCCESS'
             
END;

