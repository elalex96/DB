create PROCEDURE [dbo].[SP_CO_PreciosBrentLLSMensual]

--@CasoProduccion = 1 CUANDO EXISTA COMERCIALIZACIÓN -- @CasoProduccion = 2 CUANDO SUCEDA EL INCISO B)
@IdContrato INT,
@Mes INT,
@Año INT
AS
--DESCRIPCIÓN: VERIFICA LOS PRECIOS DE LUISIANA Y BRENT MENSUALES DE UN CONTRATO
--CREADO POR: luisdaviddela
--FECHA CREACIÓN: 05/JULIO/2018
BEGIN
DECLARE @VolumenPetroleoEntregado INT,
		@VolumenComercializadoBaseReglasMercado INT,
		@VolumenComercializado int = 0,
		@GradosAPI FLOAT,
		@ParamS DECIMAL (5, 3);
---------------------------------------------------------------------------------------------------------------
------------------------------VOLUMEN COMERCIALIZADO BAJO LAS REGLAS DEL MERCADO 
SELECT
        @VolumenComercializadoBaseReglasMercado = ISNULL( SUM( ROUND( VolumenVendido, 0 )), 0 )
	FROM
        COM_OperacionComercializacion OP
    JOIN
        CO_TipoHidrocarburo           TH
        ON OP.IdTipoHidrocarburo = TH.IdTipoHidrocarburo
    WHERE
        
        MONTH(OP.MesReporte)         = @Mes
		AND YEAR(OP.MesReporte)         = @Año
        AND OP.IdContrato                 = @IdContrato
        AND OP.OperacionBajoReglasMercado = 1
		--AND TH.TipoHidrocarburo              = 1


------------------------------ VALIDACIÓN PARA DETERMINAR QUE INCISO CAERIA 
IF @VolumenComercializadoBaseReglasMercado > 0
	BEGIN
	
		SELECT
					'Inciso A)' AS 'Método',
					CASE WHEN TH.Hidrocarburo IS NULL THEN '' ELSE TH.Hidrocarburo end 'Hidrocarburo',
					Brent.Precio AS [Precio BRENT ],
					LLS.Precio AS [Precio LLS ],
					OC.MesReporte AS 'Periodo'
            FROM
                    COM_OperacionComercializacion OC
                JOIN
                    CO_TipoHidrocarburo           TH
                    ON OC.IdTipoHidrocarburo = TH.IdTipoHidrocarburo
                JOIN
                    CO_PrecioMarcadorMensual      LLS
                    ON OC.IdContrato         = LLS.IdContrato
                    AND OC.MesReporte         = LLS.Mes
                    AND LLS.IdMarcador        = 10001
                JOIN
                    CO_PrecioMarcadorMensual      Brent
                    ON OC.IdContrato         = Brent.IdContrato
                    AND OC.MesReporte         = Brent.Mes
                    AND Brent.IdMarcador      = 10002
                WHERE
                    OC.IdContrato          = @IdContrato
                    AND MONTH(OC.MesReporte      ) = @Mes
					AND YEAR(OC.MesReporte       )= @Año
					AND TH.TipoHidrocarburo IN (SELECT tipohidrocarburo FROM dbo.CO_TipoHidrocarburo)
	END


IF(@VolumenComercializadoBaseReglasMercado <= 0  )
	BEGIN
		SELECT	
			'Inciso B)' AS 'Método',
			'Petróleo' AS 'Hidrocarburo',
			Brent.Precio AS [Precio BRENT ],

			LLS.Precio AS [Precio LLS ],
			OC.MesReporte AS 'Periodo'
           FROM
                    PR_VolumenMensualProduccionPetroleo OC
                JOIN
                    CO_PrecioMarcadorMensual      LLS
                    ON OC.IdContrato         = LLS.IdContrato
                    AND OC.MesReporte         = LLS.Mes
                    AND LLS.IdMarcador        = 10001
                JOIN
                    CO_PrecioMarcadorMensual      Brent
                    ON OC.IdContrato         = Brent.IdContrato
                    AND OC.MesReporte         = Brent.Mes
                    AND Brent.IdMarcador      = 10002
                WHERE
                   MONTH(OC.MesReporte      )= @Mes
					AND YEAR(OC.MesReporte   )=@Año
	END


END