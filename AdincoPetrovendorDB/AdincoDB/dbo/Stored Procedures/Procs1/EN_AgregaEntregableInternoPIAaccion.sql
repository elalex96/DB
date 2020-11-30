CREATE PROCEDURE [dbo].[EN_AgregaEntregableInternoPIAaccion] --10061,3,'f','f',1,'',0,'ASEA',10001,0,2
    @idUsuario INT,                      --
    @idContrato INT,                     --
    @pDocumentoEntregable VARCHAR(MAX), --
    @pDescripcion VARCHAR(MAX),         --
    @pIsActivo BIT,                      --
    @pConsecutivo VARCHAR(MAX),         --
    @pIdEntregable INT,                  --
    @ReceptorEntregable VARCHAR(200),    --
    @IdFrecuenciaEntregable INT,         --
    @EsDeProceso BIT,                    --
    @IdProgramaImplementaAccion INT,     --
    @capitulo VARCHAR(500),              --
    @articulo VARCHAR(500),              --
    @marcoLegal VARCHAR(700)             --
AS
BEGIN
-- =============================================
-- Author:		Reyna Olvera
-- Create date: 26/08/2019
-- Description:
-- =============================================
    SET NOCOUNT ON;
    DECLARE @IdRonda INT,
            @Abreviatura VARCHAR(20),
            @IdEntregableMAX INT = 0,
            @IdContratoEntregable INT,
            @IdReceptorEntregable INT,
            @idMarcoLegal INT = 0,
			@IdContratista	INT;

    SELECT @Abreviatura = CASE @idContrato
							WHEN 10112
							THEN 'CS-G01 SASISOPA'
							WHEN 10038
							THEN 'DEA-SASISOPA'
							WHEN 10044
							THEN 'DEA-SASISOPA'
							WHEN 10045
							THEN 'DEA-SASISOPA'
							WHEN 10046
							THEN 'DEA-SASISOPA'
							ELSE S.Abreviatura
						END,
		@IdContratista	=	C.IdContratista,
		 @IdRonda = C.IdRonda
    FROM dbo.CO_Contrato C
    JOIN dbo.CO_Contratista S ON C.IdContratista = S.IdContratista
    WHERE C.IdContrato = @idContrato;

	/*SELECT @IdEntregableMAX= ISNULL(MAX(E.IdEntregable), 0)
	FROM EN_ContratoEntregable CE
	JOIN EN_Entregable E on CE.IdEntregable=E.IdEntregable 
	AND CE.IdContrato=@idContrato
	AND BitInterno = 1;*/

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

    SELECT @IdReceptorEntregable = IdReceptorEntregable
    FROM dbo.EN_ReceptorEntregable
    WHERE ReceptorEntregable = @ReceptorEntregable;

    SELECT @idMarcoLegal = IdMarcoLegal
    FROM dbo.EN_MarcoLegal
    WHERE MarcoLegal = @marcoLegal;

    IF (@idMarcoLegal = 0)
    BEGIN
        INSERT INTO dbo.EN_MarcoLegal (MarcoLegal, IsInterno,CreadoPor,CreadoEn,Activo)
        VALUES (@marcoLegal, -- MarcoLegal - nvarchar(max)
                1,@idUsuario, GETDATE(),1);
        SET @idMarcoLegal = SCOPE_IDENTITY();
    END;

    IF (@IdEntregableMAX > 0)
    BEGIN
	SELECT  @pConsecutivo = @Abreviatura + '-'
                                + REPLICATE('0', 4 - LEN(LTRIM(CONVERT(INT, SUBSTRING(Consecutivo, LEN(Consecutivo) - 3, 4)) + 1))) 
                                + LTRIM(CONVERT(INT, SUBSTRING(Consecutivo, LEN(Consecutivo) - 3, 4)) + 1)
        FROM dbo.EN_Entregable
        WHERE IdEntregable =@IdEntregableMAX
    END;
    ELSE
    BEGIN
        SET @pConsecutivo = @Abreviatura + '-0000';
    END;
    --SELECT @consecutivoVar;

    INSERT INTO [dbo].[EN_Entregable] 
	([DocumentoEntregable], --México-00030
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
		Capitulo,
		Articulo,
		IdMarcoLegal,
		BitJOA)
    VALUES (@pDocumentoEntregable,
            @pDescripcion,
            @idUsuario,
            GETDATE(),
            @idUsuario,
            GETDATE(),
            1,
            0,
            @pConsecutivo,
            1,
            @IdReceptorEntregable,
           Case @IdFrecuenciaEntregable
		   when 0
		   then null
		   else
		   @IdFrecuenciaEntregable END
		   ,
            @EsDeProceso,
            @capitulo,
            @articulo,
            @idMarcoLegal,
			0);

    SET @pIdEntregable = SCOPE_IDENTITY();

    INSERT INTO dbo.EN_ContratoEntregable (IdContrato,
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
										   BitMostrarLineaTiempo)
    VALUES (@idContrato,    -- IdContrato - int
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

    INSERT INTO dbo.EN_EntregableRonda (idEntregable, idRonda)
    VALUES (@pIdEntregable, -- idEntregable - int
            @IdRonda        -- idRonda - int
        );
    INSERT INTO dbo.EN_ContratoEntregableProgramaImplementaAcciones (IdContratoEntregable,
                                                                     IdProgramaImplementaAccion,
                                                                     CreadoEl,
                                                                     CreadoPor,
                                                                     ModificadoEl,
                                                                     ModificadoPor,
                                                                     Activo)
    VALUES (@IdContratoEntregable,       -- IdContratoEntregable - int
            @IdProgramaImplementaAccion, -- IdProgramaImplementaAccion - int
            GETDATE(),                   -- CreadoEl - date
            @idUsuario,                  -- CreadoPor - int
            GETDATE(),                   -- ModificadoEl - date
            @idUsuario,                  -- ModificadoPor - int
            1                            -- Activo - bit
        );

    IF @@ERROR <> 0
    BEGIN
        SELECT @IdContratoEntregable AS IdContratoEntregable,
               @pIdEntregable AS IdEntregable,
               CAST(@@ERROR AS NVARCHAR(8)) AS error;
    END;
    ELSE
    BEGIN

        SELECT @IdContratoEntregable AS IdContratoEntregable,
               @pIdEntregable AS IdEntregable,
               '' AS error;
    END;
END;
