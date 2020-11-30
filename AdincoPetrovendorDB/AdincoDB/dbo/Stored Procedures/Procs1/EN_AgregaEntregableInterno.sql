CREATE PROCEDURE [dbo].[EN_AgregaEntregableInterno]
    @idUsuario INT,
    @idContrato INT,
    @pDocumentoEntregable VARCHAR(MAX),
    @pDescripcion VARCHAR(MAX),
    @pIsActivo BIT,
    @pConsecutivo VARCHAR(MAX),
    @pIdEntregable INT,
    @IdReceptorEntregable INT,
    @IdFrecuenciaEntregable INT,
    @EsDeProceso BIT,
    @idMarcoLegal INT,
    @Articulo VARCHAR(MAX),
    @Referencia VARCHAR(MAX),
    @Condicion VARCHAR(MAX),
    @TiempoEntrega VARCHAR(MAX),
    @actividad VARCHAR(MAX)
AS
BEGIN
-- =============================================
-- Author:      Reyna Olvera
-- Create date: 18/05/2019
-- Description:Guarda entregables internas
-- =============================================
    SET NOCOUNT ON;
    DECLARE @IdRonda INT,
            @Abreviatura VARCHAR(20),
            @IdEntregableMAX INT = 0,
            @IdContratoEntregable INT,
			@IdContratista	INT;

    SELECT @IdRonda	=	IdRonda
    FROM	dbo.CO_Contrato
    WHERE	IdContrato	=	@idContrato;

    SELECT @Abreviatura	=	S.Abreviatura,
		   @IdContratista	=	C.IdContratista
    FROM	dbo.CO_Contrato	C
    JOIN	dbo.CO_Contratista	S
		ON	C.IdContratista	=	S.IdContratista
    WHERE	C.IdContrato	=	@idContrato;

  --  SELECT	@IdEntregableMAX	=	ISNULL(MAX(E.IdEntregable), 0)
  --  FROM	EN_ContratoEntregable	CE
  --  JOIN	EN_Entregable	E	ON	CE.IdEntregable=E.IdEntregable 
		--AND	CE.IdContrato	=	@idContrato
		--AND BitInterno	=	1;
    
	SELECT 
		@IdEntregableMAX	=	ISNULL(MAX(E.IdEntregable), 0)
	FROM	CO_Contrato	C
	JOIN 
		EN_ContratoEntregable	CE
		ON	C.IdContrato	=	CE.IdContrato
		AND C.IdContratista	=	@IdContratista
	JOIN 
		EN_Entregable	E
		ON CE.IdEntregable	=	E.IdEntregable 
		AND E.BitInterno	=	1
		AND E.BitJOA	=	0


IF (@IdEntregableMAX > 0)
BEGIN
SELECT  @pConsecutivo	=	@Abreviatura	+	'-'
                            + REPLICATE('0', 4 - LEN(LTRIM(CONVERT(INT, SUBSTRING(Consecutivo, LEN(Consecutivo) - 3, 4)) + 1))) 
                            + LTRIM	(CONVERT(INT, SUBSTRING(Consecutivo, LEN(Consecutivo) - 3, 4)) + 1)
    FROM dbo.EN_Entregable
    WHERE IdEntregable	=	@IdEntregableMAX
      
END;
ELSE
BEGIN
    SET @pConsecutivo	=	@Abreviatura	+	'-0000';
END;

    INSERT INTO [dbo].[EN_Entregable]
    (
        [DocumentoEntregable],
        [Descripcion],
        [CreadoPor],
        [CreadoEn],
        [ModificadoPor],
        [ModificadoEn],
        [IsActivo],
        [IsEliminado],
        [Consecutivo],
        [BitInterno],
        [IdReceptorEntregable],
        [IdFrecuenciaEntregable],
        EsDeProceso,
        IdMarcoLegal,
        Articulo,
        Apartado,
        Observaciones,
        TiempoEntrega,
        Actividad,
		BitJOA
    )
    VALUES
    (   @pDocumentoEntregable,	@pDescripcion,	@idUsuario, GETDATE(), @idUsuario, GETDATE(), 1, 0, @pConsecutivo, 1,
        CASE @IdReceptorEntregable
            WHEN 0	 THEN	NULL
			ELSE	@IdReceptorEntregable
		END, 
		@IdFrecuenciaEntregable, @EsDeProceso,
		 CASE @idMarcoLegal
             WHEN 0 THEN	NULL
	         ELSE	@idMarcoLegal
         END,
		 @Articulo, @Referencia, @Condicion, @TiempoEntrega, @actividad, 0);
    
SET @pIdEntregable = SCOPE_IDENTITY();
    INSERT INTO dbo.EN_ContratoEntregable
    (
        IdContrato,
        IdEntregable,
        DiasRevision,
        DiasAprobacion,
        DiasAlerta,
        CreadoPor,
        CreadoEl,
        ModificadoPor,
        ModificadoEl,
        Activo,
        DiasElaboracion,
		ContieneInformacionSensible,
		BitMostrarLineaTiempo
    )
    VALUES
    (   @idContrato,    -- IdContrato - int
        @pIdEntregable, -- IdEntregable - int
        0,              -- DiasRevision - int
        0,              -- DiasAprobacion - int
        0,              -- DiasAlerta - int
        @idUsuario,     -- CreadoPor - int
        GETDATE(),      -- CreadoEl - datetime
        @idUsuario,     -- ModificadoPor - int
        GETDATE(),      -- ModificadoEl - datetime
        1,              -- Activo - bit
        0,               -- DiasElaboracion - int
		0,0
	);

    SET @IdContratoEntregable = @@IDENTITY;

    INSERT INTO dbo.EN_EntregableRonda
	(
        idEntregable,
        idRonda
    )
    VALUES
    (   @pIdEntregable, --		idEntregable - int
        @IdRonda        -- idRonda - int
     );

    IF @@ERROR <> 0
        SELECT @IdContratoEntregable AS IdContratoEntregable,
               @pIdEntregable AS IdEntregable,
               CAST(@@ERROR AS NVARCHAR(8)) AS error;
  ELSE
        SELECT @IdContratoEntregable AS IdContratoEntregable,
               @pIdEntregable AS IdEntregable,
               '' AS error;
END;
