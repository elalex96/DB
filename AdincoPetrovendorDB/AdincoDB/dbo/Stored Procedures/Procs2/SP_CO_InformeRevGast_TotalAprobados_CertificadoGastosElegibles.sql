--====================================
-- Modificado por: Reyna olvera
-- Modificado el:24/11/2022
-- Descripción: Se agrega el campo: ImporteEstimadoParcial para los gastos aporbados 
-- por importes o montos parciales, en caso de ser aprobados con monto 0, significa que se aprobo el total del gasto y se muestra el MontoUSDConMarkup de la vista de gastos
--====================================
CREATE PROCEDURE [dbo].[SP_CO_InformeRevGast_TotalAprobados_CertificadoGastosElegibles]
    @IdPresupuesto   INT,
    @MesPresentacion DATE
AS
    BEGIN
        SET LANGUAGE SPANISH;
        DECLARE @Contrato INT;
        DECLARE @FechaSumaMes DATE = DATEADD(month, 1, @MesPresentacion)
        DECLARE
            @Fecha                          VARCHAR(150) = '',
            @FechaRevGastosElegibles        VARCHAR(150) = '',
            @FechaGastosPendientesReconocer VARCHAR(150) = '',
            @FechaInformeContableGastos     VARCHAR(200) = '',
            @Presupuesto                    VARCHAR(150) = ''

        SET @Fecha = LTRIM(UPPER(CONCAT(datename(month, @MesPresentacion), '/', YEAR(@MesPresentacion))));
        SET @FechaRevGastosElegibles
            = LTRIM(CONCAT(
                              '(Ver el Informe de Revisión de Gastos Elegibles ', datename(month, @MesPresentacion),
                              '/', YEAR(@MesPresentacion), ')'
                          )
                   );

        SET @FechaGastosPendientesReconocer
            = LTRIM(CONCAT(
                              '(Ver el Informe de Saldos de Gastos Elegibles Pendientes de Reconocer a ',
                              datename(month, @MesPresentacion), '/', YEAR(@MesPresentacion), ')'
                          )
                   );

        SET @FechaInformeContableGastos
            = LTRIM(CONCAT(
                              'De acuerdo al Informe Contable de Gastos elegibles correspondiente al mes de ',
                              datename(month, @MesPresentacion), ' ', YEAR(@MesPresentacion),
                              ' que se presento con fecha de 06/', RIGHT('0' + RTRIM(MONTH(@FechaSumaMes)), 2), '/',
                              YEAR(@FechaSumaMes), ' le notifico lo siguiente de acuerdo a nuestra revisión:'
                          )
                   );

        SET @Presupuesto =
            (
                SELECT TOP 1
                    Nombre
                FROM
                    CO_Presupuesto
                WHERE
                    IdPresupuesto = @IdPresupuesto
            );


        SET @Presupuesto = LTRIM(UPPER(@Presupuesto));

        SELECT TOP 1
            @Contrato = CO_PeriodoContrato.IdContrato
        FROM
            CO_Presupuesto (NOLOCK)
            JOIN
                CO_ProgramaActividad (NOLOCK)
                    ON CO_Presupuesto.IdProgramaActividad = CO_ProgramaActividad.IdProgramaActividad
            JOIN
                CO_PeriodoContrato (NOLOCK)
                    ON CO_ProgramaActividad.IdPeriodoContrato = CO_PeriodoContrato.IdPeriodo
        WHERE
            CO_Presupuesto.IdPresupuesto = @IdPresupuesto

        SELECT
            ISNULL(
                      SUM(  
						  CASE 
						  WHEN 
								ISNULL(CO_RegistroMarkup.ImporteEstimadoParcial, 0) <> 0
						  THEN
							  CAST(
									ISNULL(CO_RegistroMarkup.ImporteEstimadoParcial, 0)
										  / (CASE
												 WHEN CO_Registro.CvTipoDocFacturacion = 1
													 THEN ISNULL(CO_RegistroMarkup.TipoCambio, TCDF.TipoCambio)
												 WHEN CO_Registro.CvTipoDocFacturacion IN (
																							  2, 3
																						  )
													 THEN ISNULL(CO_RegistroMarkup.TipoCambio, TCDPC.TipoCambio)
												 ELSE
													 0
											 END
											) AS DECIMAL(15, 2))
							ELSE
								GastosAmatitlan2020.MontoUSDConMarkup
							END
                         ), 0.00
                  )                         AS TOTAL,
            @Fecha                          AS MES,
            @FechaRevGastosElegibles        AS MesRevGastosElegibles,
            @FechaGastosPendientesReconocer AS MesGastosPendientesReconocer,
            @FechaInformeContableGastos     AS MesInformeContableGastos,
            @Presupuesto                    AS Presupuesto
        FROM
            dbo.CO_LineaPresupuestoMes WITH (NOLOCK)
            JOIN
                dbo.CO_Registro WITH (NOLOCK)
                    ON CO_Registro.IdPrograma = CO_LineaPresupuestoMes.IdLineaPresupuestoMes
                       AND CO_LineaPresupuestoMes.IdPresupuesto = @IdPresupuesto
            JOIN
                CO_RegistroMarkup        CO_RegistroMarkup	(NOLOCK)
                    ON CO_Registro.IdRegistro = CO_RegistroMarkup.gastoId
            JOIN
                CO_EstadoRegistro_V2	(NOLOCK)
                    ON ISNULL(CO_RegistroMarkup.IdEstadoPemex, 0) = CO_EstadoRegistro_V2.IdClvEstado
                       AND CO_RegistroMarkup.MesEstadoPemex = @MesPresentacion
                       AND CO_EstadoRegistro_V2.NombreEstado = 'Certificado GE Aprobado CACI'
                       AND CO_EstadoRegistro_V2.IdContrato = @Contrato
			JOIN 
				GastosAmatitlan2020 (NOLOCK)
				ON CO_Registro.IdRegistro = GastosAmatitlan2020.IdRegistro
            LEFT JOIN
                FI_Factura	(NOLOCK)
                    on CO_Registro.idfactura = FI_Factura.idfactura
            LEFT JOIN
                dbo.FI_PedimentoComprobante WITH (NOLOCK)
                    ON CO_Registro.IdPedimentoComprobante = FI_PedimentoComprobante.IdPedimentoComprobante
            LEFT JOIN
                dbo.PV_TipoMoneda        AS TMF WITH (NOLOCK)
                    ON TMF.IdMoneda = FI_Factura.IdMoneda
            LEFT JOIN
                dbo.CO_TipoCambioMensual AS TCDF WITH (NOLOCK)
                    ON TCDF.IdMoneda = TMF.IdMoneda
                       AND TCDF.Anio = YEAR(FI_Factura.Fecha)
                       AND TCDF.IdMes = MONTH(FI_Factura.Fecha)
            LEFT JOIN
                dbo.PV_TipoMoneda        AS TMPC WITH (NOLOCK)
                    ON TMPC.IdMoneda = FI_PedimentoComprobante.IdMoneda
            LEFT JOIN
                dbo.CO_TipoCambioMensual AS TCDPC WITH (NOLOCK)
                    ON TCDPC.IdMoneda = TMPC.IdMoneda
                       AND TCDPC.Anio = YEAR(FI_PedimentoComprobante.FechaPago)
                       AND TCDPC.IdMes = MONTH(FI_PedimentoComprobante.FechaPago)
        WHERE
            CO_RegistroMarkup.MesEstadoPemex = @MesPresentacion
            AND CO_LineaPresupuestoMes.IdPresupuesto = @IdPresupuesto
            AND CO_EstadoRegistro_V2.NombreEstado = 'Certificado GE Aprobado CACI'

    END;
