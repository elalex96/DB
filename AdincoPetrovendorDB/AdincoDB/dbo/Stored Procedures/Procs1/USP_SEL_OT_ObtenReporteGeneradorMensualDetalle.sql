IF EXISTS
    (
        SELECT
            1
        FROM
            dbo.sysobjects
        WHERE
            name = 'USP_SEL_OT_ObtenReporteGeneradorMensualDetalle'
    )
    DROP PROCEDURE USP_SEL_OT_ObtenReporteGeneradorMensualDetalle
GO
CREATE PROCEDURE [dbo].[USP_SEL_OT_ObtenReporteGeneradorMensualDetalle] --1,1,'20221101',2889
    @ContratoId    INT,
    @UsuarioId     INT,
    @Mes           DATE ,
    @OTSolicitudId INT 
AS
    BEGIN
        SET NOCOUNT ON
		
        DECLARE @DiasMes TABLE
            (
                IdFecha DATE,
                Dia     INT
            );
        DECLARE @Materiales TABLE
            (
                IdOTSolicitudMaterial INT,
                Posicion              VARCHAR(300),
                Concepto              VARCHAR(1500),
                Unidad                VARCHAR(300),
                SeriePersonal         VARCHAR(300),
                Marca                 VARCHAR(300),
                PrecioUnitario        FLOAT,
                TextoPosicion         VARCHAR(1500),
				FechaInicioRentaServ DATE,
				TotalDiasHH FLOAT,
				CostoTotalMXP FLOAT,
				CostoTotalUSD FLOAT,
				Moneda varchar(50),
				MonedaId INT
            );

        DECLARE @DiasMesCapturaMaterial TABLE
            (
                IdFecha               DATE,
                Dia                   INT,
                IdOTSolicitudMaterial INT,
                Captura               FLOAT NULL
            );

		DECLARE @FechaInicialCapturaMateriales TABLE
            (
				IdOTSolicitudMaterial INT,
				FechaInicioRentaServ DATE,
				TotalDiasHH FLOAT,
				CostoTotalMXP FLOAT,
				CostoTotalUSD FLOAT
            );

			   	DECLARE @TotalSinIvaMXP FLOAT ,
		    @TotalSinIvaUSD FLOAT ,
			@IvaMXP FLOAT ,
			@IvaUSD FLOAT ,
			@TotalConIvaMXP FLOAT ,
			@TotalConIvaUSD FLOAT ;

		
        INSERT INTO @DiasMes
            (
                IdFecha,
                Dia
            )
                    SELECT
                        IdFecha,
                        Dia
                    FROM
                        AP_CALENDARIO
                    WHERE
                        Anio = YEAR(@Mes)
                        AND MES = MONTH(@Mes);


        INSERT INTO @Materiales
            (
                IdOTSolicitudMaterial,
                Posicion,
                Concepto,
                Unidad,
                SeriePersonal,
                Marca,
                PrecioUnitario,
                TextoPosicion,
				MonedaId
            )
                    SELECT
                        OT_SolicitudProgramaCaptura.IdOTSolicitudMaterial,
                        LTRIM(RTRIM(SUBSTRING(
                                                 SC_Materiales.Concepto, CHARINDEX('-', SC_Materiales.Concepto) + 1,
                                                 LEN(SC_Materiales.Concepto)
                                             )
                                   )
                             )                         AS Posicion,
                                UPPER( CAST('[' + SC_Materiales.Concepto + ']' + SC_Materiales.Descripcion AS VARCHAR(200)))                        
					   AS Concepto,
                       UPPER( CAST(U.Unidad AS VARCHAR(300)) ) AS Unidad,
                        ''                             AS SeriePersonal,
                        ''                            AS Marca,
                        SC_Materiales.PrecioUnitario   AS PrecioUnitario,
                        [OT_SolicitudMaterial].Comentarios                           AS TextoPosicion,
						SC_SubContrato.IdMoneda
                    FROM
                        [dbo].[OT_SolicitudMaterial] (NOLOCK)
                        JOIN
                            SC_Materiales (NOLOCK)
                                on OT_SolicitudMaterial.IdOTSolicitud = @OTSolicitudId
                                   AND OT_SolicitudMaterial.IdSCMaterial = SC_Materiales.IdSCMaterial
                        JOIN
                            [dbo].[OT_SolicitudProgramaCaptura] (NOLOCK)
                                ON OT_SolicitudMaterial.IdOTSolicitudMaterial = OT_SolicitudProgramaCaptura.IdOTSolicitudMaterial
                                   AND [OT_SolicitudProgramaCaptura].VoBoContratista = 1
                                   AND [OT_SolicitudProgramaCaptura].VoBoSubcontratista = 1
                                   AND (
                                           MONTH(OT_SolicitudProgramaCaptura.Fecha) = MONTH(@Mes)
                                           AND YEAR(OT_SolicitudProgramaCaptura.Fecha) = YEAR(@Mes)
                                       )
                        JOIN
                            dbo.OT_ProgramaSemanaCerrada (NOLOCK)
                                ON OT_ProgramaSemanaCerrada.IdOTSolicitud = @OTSolicitudId
                                   AND OT_SolicitudProgramaCaptura.Fecha
                                   BETWEEN OT_ProgramaSemanaCerrada.FechaSemanaIni AND OT_ProgramaSemanaCerrada.FechaSemanaFin
                                   AND OT_ProgramaSemanaCerrada.isActivo = 1
						JOIN
							SC_SubContrato	(NOLOCK)
							ON	
								SC_Materiales.IdSubContrato	=	SC_SubContrato.IdSubContrato
                        JOIN
                            Petrovendor.dbo.[PV_MM_MaterialUnidad] u (NOLOCK)
                                on SC_Materiales.IdUnidad = u.IdUnidad
                    WHERE
                        OT_SolicitudMaterial.IdOTSolicitud = @OTSolicitudId
                        AND VoBoContratista = 1
                        AND VoBoSubcontratista = 1
                        AND (
                                MONTH(OT_SolicitudProgramaCaptura.Fecha) = MONTH(@Mes)
                                AND YEAR(OT_SolicitudProgramaCaptura.Fecha) = YEAR(@Mes)
                            )
                    group by
                        OT_SolicitudProgramaCaptura.IdOTSolicitudMaterial,
                        LTRIM(RTRIM(SUBSTRING(
                                                 SC_Materiales.Concepto, CHARINDEX('-', SC_Materiales.Concepto) + 1,
                                                 LEN(SC_Materiales.Concepto)
                                             )
                                   )
                             ),
                               UPPER(  CAST('[' + SC_Materiales.Concepto + ']' + SC_Materiales.Descripcion AS VARCHAR(200))),
                       UPPER( CAST(U.Unidad AS VARCHAR(300))),
                        SC_Materiales.PrecioUnitario,
						OT_SolicitudMaterial.Comentarios,
						SC_SubContrato.IdMoneda;

			
			UPDATE Materiales
			SET	Moneda = TipoMonedaCorto
			FROM 
				@Materiales	AS Materiales
			JOIN
				PV_TipoMoneda (NOLOCK)
				ON
					Materiales.MonedaId	=	PV_TipoMoneda.IdMoneda;

        INSERT INTO @DiasMesCapturaMaterial
            (
                IdFecha,
                Dia,
                IdOTSolicitudMaterial
            )
                    SELECT
                        IdFecha,
                        Dia,
                        IdOTSolicitudMaterial
                    FROM
                        @Materiales
                        CROSS JOIN @DiasMes;

        UPDATE
            DiasMesCapturaMaterial
        SET
            Captura = [OT_SolicitudProgramaCaptura].Captura
        FROM
            @DiasMesCapturaMaterial AS DiasMesCapturaMaterial
            JOIN
                [dbo].[OT_SolicitudProgramaCaptura] (NOLOCK)
                    ON DiasMesCapturaMaterial.IdOTSolicitudMaterial = OT_SolicitudProgramaCaptura.IdOTSolicitudMaterial
                       AND CONVERT(DATE, DiasMesCapturaMaterial.IdFecha) = CONVERT(
                                                                                      DATE,
                                                                                      OT_SolicitudProgramaCaptura.Fecha
                                                                                  )
            JOIN
                dbo.OT_ProgramaSemanaCerrada (NOLOCK)
                    ON OT_ProgramaSemanaCerrada.IdOTSolicitud = @OTSolicitudId
                       AND OT_SolicitudProgramaCaptura.Fecha
                       BETWEEN OT_ProgramaSemanaCerrada.FechaSemanaIni AND OT_ProgramaSemanaCerrada.FechaSemanaFin
                       AND OT_ProgramaSemanaCerrada.isActivo = 1
        WHERE
            VoBoContratista = 1
            AND VoBoSubcontratista = 1;

		

			INSERT INTO @FechaInicialCapturaMateriales 
            (
				IdOTSolicitudMaterial ,
				FechaInicioRentaServ ,
				TotalDiasHH ,
				CostoTotalMXP ,
				CostoTotalUSD 
            )
			SELECT 
				Materiales.IdOTSolicitudMaterial,
				FechaInicioRentaServ = MIN(DiasMesCapturaMaterial.IdFecha),
				TotalDiasHH = SUM(ISNULL(DiasMesCapturaMaterial.Captura,0)),
				CostoTotalMXP = 
				CASE
				WHEN
					Materiales.MONEDA = 'MXN'
				THEN 
					SUM(ISNULL(DiasMesCapturaMaterial.Captura,0)) * Materiales.PrecioUnitario
					ELSE
					NULL
				END,
				CostoTotalUSD = 
				CASE 
				WHEN 
					Materiales.MONEDA = 'USD'
				THEN 
					SUM(ISNULL(DiasMesCapturaMaterial.Captura,0)) * Materiales.PrecioUnitario
				ELSE 
					NULL
				END
			   FROM
            @Materiales                 AS Materiales
            JOIN
                @DiasMesCapturaMaterial AS DiasMesCapturaMaterial
                    ON Materiales.IdOTSolicitudMaterial = DiasMesCapturaMaterial.IdOTSolicitudMaterial
					WHERE ISNULL(DiasMesCapturaMaterial.Captura,0) > 0
			GROUP BY 
				Materiales.IdOTSolicitudMaterial,
				Materiales.PrecioUnitario,
				Materiales.PrecioUnitario,
				Materiales.MONEDA;

				UPDATE Materiales
					SET 
					Materiales.FechaInicioRentaServ = FechaInicialCapturaMateriales.FechaInicioRentaServ,
					Materiales.TotalDiasHH  = FechaInicialCapturaMateriales.TotalDiasHH,
					Materiales.CostoTotalMXP  = FechaInicialCapturaMateriales.CostoTotalMXP,
					Materiales.CostoTotalUSD  = FechaInicialCapturaMateriales.CostoTotalUSD
				FROM
					@FechaInicialCapturaMateriales AS FechaInicialCapturaMateriales
				JOIN
					@Materiales                 AS Materiales
					ON 
						FechaInicialCapturaMateriales.IdOTSolicitudMaterial	=      Materiales.IdOTSolicitudMaterial;

		IF((SELECT TOP 1 MONEDA FROM @Materiales ) = 'MXN')
		BEGIN
			SELECT @TotalSinIvaMXP = SUM(CostoTotalMXP) FROM @Materiales;
			SELECT @IvaMXP = @TotalSinIvaMXP * .16;
			SELECT @TotalConIvaMXP = @TotalSinIvaMXP	+	@IvaMXP;
		END

		IF((SELECT TOP 1 MONEDA FROM @Materiales ) = 'USD')
		BEGIN
			SELECT @TotalSinIvaUSD = SUM(CostoTotalMXP) FROM @Materiales;
			SELECT @IvaUSD = @TotalSinIvaUSD * .16;
			SELECT @TotalConIvaUSD = @TotalSinIvaUSD	+	@IvaUSD;
		END
		   

        SELECT
            Materiales.IdOTSolicitudMaterial,
            Materiales.Posicion,
            Materiales.Concepto,
            Materiales.Unidad,
            Materiales.SeriePersonal,
            Materiales.Marca,
            Materiales.PrecioUnitario,
            Materiales.TextoPosicion,
			Materiales.FechaInicioRentaServ ,
			Materiales.TotalDiasHH,
			Materiales.CostoTotalMXP,
			Materiales.CostoTotalUSD,
			@TotalSinIvaMXP AS TotalSinIvaMXP,
			@TotalSinIvaUSD AS TotalSinIvaUSD,
			@IvaMXP AS IvaMXP,
			@IvaUSD AS IvaUSD,
			@TotalConIvaMXP AS TotalConIvaMXP,
			@TotalConIvaUSD AS TotalConIvaUSD,
            MAX(   CASE
                       WHEN DiasMesCapturaMaterial.Dia = 1
                           THEN DiasMesCapturaMaterial.Captura
                       ELSE
                           NULL
                   END
               ) AS 'Dia1',
            MAX(   CASE
                       WHEN DiasMesCapturaMaterial.Dia = 2
                           THEN DiasMesCapturaMaterial.Captura
                       ELSE
                           NULL
                   END
               ) AS 'Dia2',
            MAX(   CASE
                       WHEN DiasMesCapturaMaterial.Dia = 3
                           THEN DiasMesCapturaMaterial.Captura
                       ELSE
                           NULL
                   END
               ) AS 'Dia3',
            MAX(   CASE
                       WHEN DiasMesCapturaMaterial.Dia = 4
                           THEN DiasMesCapturaMaterial.Captura
                       ELSE
                           NULL
                   END
               ) AS 'Dia4',
            MAX(   CASE
                       WHEN DiasMesCapturaMaterial.Dia = 5
                           THEN DiasMesCapturaMaterial.Captura
                       ELSE
                           NULL
                   END
               ) AS 'Dia5',
            MAX(   CASE
                       WHEN DiasMesCapturaMaterial.Dia = 6
                           THEN DiasMesCapturaMaterial.Captura
                       ELSE
                           NULL
                   END
               ) AS 'Dia6',
            MAX(   CASE
                       WHEN DiasMesCapturaMaterial.Dia = 7
                           THEN DiasMesCapturaMaterial.Captura
                       ELSE
                           NULL
                   END
               ) AS 'Dia7',
            MAX(   CASE
                       WHEN DiasMesCapturaMaterial.Dia = 8
                           THEN DiasMesCapturaMaterial.Captura
                       ELSE
                           NULL
                   END
               ) AS 'Dia8',
            MAX(   CASE
                       WHEN DiasMesCapturaMaterial.Dia = 9
                           THEN DiasMesCapturaMaterial.Captura
                       ELSE
                           NULL
                   END
               ) AS 'Dia9',
            MAX(   CASE
                       WHEN DiasMesCapturaMaterial.Dia = 10
                           THEN DiasMesCapturaMaterial.Captura
                       ELSE
                           NULL
                   END
               ) AS 'Dia10',
            MAX(   CASE
                       WHEN DiasMesCapturaMaterial.Dia = 11
                           THEN DiasMesCapturaMaterial.Captura
                       ELSE
                           NULL
                   END
               ) AS 'Dia11',
            MAX(   CASE
                       WHEN DiasMesCapturaMaterial.Dia = 12
                           THEN DiasMesCapturaMaterial.Captura
                       ELSE
                           NULL
                   END
               ) AS 'Dia12',
            MAX(   CASE
                       WHEN DiasMesCapturaMaterial.Dia = 13
                           THEN DiasMesCapturaMaterial.Captura
                       ELSE
                           NULL
                   END
               ) AS 'Dia13',
            MAX(   CASE
                       WHEN DiasMesCapturaMaterial.Dia = 14
                           THEN DiasMesCapturaMaterial.Captura
                       ELSE
                           NULL
                   END
               ) AS 'Dia14',
            MAX(   CASE
                       WHEN DiasMesCapturaMaterial.Dia = 15
                           THEN DiasMesCapturaMaterial.Captura
                       ELSE
                           NULL
                   END
               ) AS 'Dia15',
            MAX(   CASE
                       WHEN DiasMesCapturaMaterial.Dia = 16
                           THEN DiasMesCapturaMaterial.Captura
                       ELSE
                           NULL
                   END
               ) AS 'Dia16',
            MAX(   CASE
                       WHEN DiasMesCapturaMaterial.Dia = 17
                           THEN DiasMesCapturaMaterial.Captura
                       ELSE
                           NULL
                   END
               ) AS 'Dia17',
            MAX(   CASE
                       WHEN DiasMesCapturaMaterial.Dia = 18
                           THEN DiasMesCapturaMaterial.Captura
                       ELSE
                           NULL
                   END
               ) AS 'Dia18',
            MAX(   CASE
                       WHEN DiasMesCapturaMaterial.Dia = 19
                           THEN DiasMesCapturaMaterial.Captura
                       ELSE
                           NULL
                   END
               ) AS 'Dia19',
            MAX(   CASE
                       WHEN DiasMesCapturaMaterial.Dia = 20
                           THEN DiasMesCapturaMaterial.Captura
                       ELSE
                           NULL
                   END
               ) AS 'Dia20',
            MAX(   CASE
                       WHEN DiasMesCapturaMaterial.Dia = 21
                           THEN DiasMesCapturaMaterial.Captura
                       ELSE
                           NULL
                   END
               ) AS 'Dia21',
            MAX(   CASE
                       WHEN DiasMesCapturaMaterial.Dia = 22
                           THEN DiasMesCapturaMaterial.Captura
                       ELSE
                           NULL
                   END
               ) AS 'Dia22',
            MAX(   CASE
                       WHEN DiasMesCapturaMaterial.Dia = 23
                           THEN DiasMesCapturaMaterial.Captura
                       ELSE
                           NULL
                   END
               ) AS 'Dia23',
            MAX(   CASE
                       WHEN DiasMesCapturaMaterial.Dia = 24
                           THEN DiasMesCapturaMaterial.Captura
                       ELSE
                           NULL
                   END
               ) AS 'Dia24',
            MAX(   CASE
                       WHEN DiasMesCapturaMaterial.Dia = 25
                           THEN DiasMesCapturaMaterial.Captura
                       ELSE
                           NULL
                   END
               ) AS 'Dia25',
            MAX(   CASE
                       WHEN DiasMesCapturaMaterial.Dia = 26
                           THEN DiasMesCapturaMaterial.Captura
                       ELSE
                           NULL
                   END
               ) AS 'Dia26',
            MAX(   CASE
                       WHEN DiasMesCapturaMaterial.Dia = 27
                           THEN DiasMesCapturaMaterial.Captura
                       ELSE
                           NULL
                   END
               ) AS 'Dia27',
            MAX(   CASE
                       WHEN DiasMesCapturaMaterial.Dia = 28
                           THEN DiasMesCapturaMaterial.Captura
                       ELSE
                           NULL
                   END
               ) AS 'Dia28',
            MAX(   CASE
                       WHEN DiasMesCapturaMaterial.Dia = 29
                           THEN DiasMesCapturaMaterial.Captura
                       ELSE
                           NULL
                   END
               ) AS 'Dia29',
            MAX(   CASE
                       WHEN DiasMesCapturaMaterial.Dia = 30
                           THEN DiasMesCapturaMaterial.Captura
                       ELSE
                           NULL
                   END
               ) AS 'Dia30',
            MAX(   CASE
                       WHEN DiasMesCapturaMaterial.Dia = 31
                           THEN DiasMesCapturaMaterial.Captura
                       ELSE
                           NULL
                   END
               ) AS 'Dia31'
        FROM
            @Materiales                 AS Materiales
            JOIN
                @DiasMesCapturaMaterial AS DiasMesCapturaMaterial
                    ON Materiales.IdOTSolicitudMaterial = DiasMesCapturaMaterial.IdOTSolicitudMaterial
        GROUP BY
            Materiales.IdOTSolicitudMaterial,
            Materiales.Posicion,
            Materiales.Concepto,
            Materiales.Unidad,
            Materiales.SeriePersonal,
            Materiales.Marca,
            Materiales.PrecioUnitario,
            Materiales.TextoPosicion,
			Materiales.FechaInicioRentaServ ,
			Materiales.TotalDiasHH,
			Materiales.CostoTotalMXP,
			Materiales.CostoTotalUSD
        ORDER BY
            Materiales.IdOTSolicitudMaterial;

    END;




