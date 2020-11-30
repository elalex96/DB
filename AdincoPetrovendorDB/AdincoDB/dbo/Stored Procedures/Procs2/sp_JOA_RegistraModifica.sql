CREATE PROCEDURE [dbo].[sp_JOA_RegistraModifica]
    @idUsuario
 INT,
	@idContrato INT,
	@idSocio INT,
	@idEntregable INT,
	@IdClasificacion INT,
	@IdFrecuenciaEntregable INT,
	@Apartado varchar(8000),
	@Inciso varchar(8000),
	@DocumentoEntregable varchar(8000),
	@Articulo varchar(8000),
	@Observaciones varchar(8000),
	@IdMarcoLegal INT,
	@Sensible INT
AS
BEGIN
    SET NOCOUNT ON;
	DECLARE @Consecutivo VARCHAR(8000),@Abreviatura VARCHAR(10),@IdContratista INT, @IdEntregableMAX INT ;

	IF(@idEntregable	=	0)
	BEGIN
		SELECT @Abreviatura = S.Abreviatura,
			   @IdContratista	=	C.IdContratista
		FROM 
			dbo.CO_Contrato C
		JOIN 
			dbo.CO_Contratista S
			ON C.IdContratista = S.IdContratista
		WHERE 
			C.IdContrato = @idContrato;


		SELECT 
			@IdEntregableMAX	=	ISNULL(MAX(E.IdEntregable), 0)
		FROM	
			CO_Contrato	C
		JOIN 
			EN_ContratoEntregable	CE
			ON	C.IdContrato	=	CE.IdContrato
			AND C.IdContratista	=	@IdContratista
		JOIN 
			EN_Entregable	E
			ON CE.IdEntregable	=	E.IdEntregable 
			AND BitJOA	=	1;



    IF (@IdEntregableMAX > 0)
    BEGIN
			SELECT  @Consecutivo = 'JOA-' + @Abreviatura + '-'
                                + REPLICATE('0', 4 - LEN(LTRIM(CONVERT(INT, SUBSTRING(Consecutivo, LEN(Consecutivo) - 3, 4)) + 1))) 
                                + 
				LTRIM(
				CONVERT(INT, SUBSTRING(Consecutivo, LEN(Consecutivo) - 3, 4)) + 1)
			FROM 
				dbo.EN_Entregable
			WHERE 
				IdEntregable =@IdEntregableMAX

	END;
		ELSE
	BEGIN
			SET @Consecutivo = 'JOA-'+@Abreviatura + '-0000';
	END;


	INSERT INTO EN_Entregable(DocumentoEntregable,DeliverableName,Articulo,Inciso,Apartado,Observaciones,IdClasificacion,IdFrecuenciaEntregable,BitJOA,   IdMarcoLegal,      CreadoPor,CreadoEn,IsActivo,IsEliminado,Consecutivo)
	VALUES				 (@DocumentoEntregable,@DocumentoEntregable,@Articulo,@Inciso,@Apartado,@Observaciones,@IdClasificacion,@IdFrecuenciaEntregable,1,@IdMarcoLegal,    @idUsuario,GETDATE(),1,0,@Consecutivo);

			
			
    SET @idEntregable = SCOPE_IDENTITY();


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
										ContieneInformacionSensible)
	SELECT  IdContrato,    -- IdContrato - int
            @idEntregable, -- IdEntregable - int
            1,              -- DiasRevision - int
            1,              -- DiasAprobacion - int
            1,              -- DiasAlerta - int
            @idUsuario,     -- CreadoPor - int
            GETDATE(),      -- CreadoEl - datetime
            @idUsuario,     -- ModificadoPor - int
            GETDATE(),      -- ModificadoEl - datetime
            1,              -- Activo - bit
            1,              -- DiasElaboracion - int,
			@Sensible
        
	FROM 
		CO_ContratoSocio
	WHERE 
		IdContratistaSocio = @idSocio

	INSERT INTO dbo.EN_EntregableRonda (idEntregable, idRonda)
	SELECT @idEntregable, -- idEntregable - int
		C.IdRonda        -- idRonda - int
	FROM 
		CO_ContratoSocio	CS
	JOIN
		CO_CONTRATO	C
		ON	CS.IdContrato	=	C.IdContrato
	WHERE 
		CS.IdContratistaSocio = @idSocio
	GROUP BY C.IdRonda

   
	END
	ELSE
	BEGIN
		UPDATE 
			EN_Entregable
		SET	DocumentoEntregable	=	@DocumentoEntregable,
			DeliverableName	=	@DocumentoEntregable,
			Articulo	=	@Articulo,
			Inciso	=	@Inciso,
			Apartado	=	@Apartado,
			Observaciones	=	@Observaciones,
			IdClasificacion	=	@IdClasificacion,
			IdFrecuenciaEntregable	=	@IdFrecuenciaEntregable,
			ModificadoPor	=	@idUsuario,
			ModificadoEn	=	GETDATE(),
			IdMarcoLegal	=	@IdMarcoLegal
		WHERE 
			IdEntregable	=	@idEntregable


		UPDATE
			EN_ContratoEntregable
			SET 
				ContieneInformacionSensible	=	@Sensible
			WHERE 
				IdEntregable	=	@idEntregable	

	END
	 SELECT @idEntregable AS idEntregable
	
END


