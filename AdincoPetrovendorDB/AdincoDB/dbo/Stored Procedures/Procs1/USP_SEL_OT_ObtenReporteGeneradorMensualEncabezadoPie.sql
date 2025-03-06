
IF EXISTS
    (
        SELECT
            1
        FROM
            dbo.sysobjects
        WHERE
            name = 'USP_SEL_OT_ObtenReporteGeneradorMensualEncabezadoPie'
    )
    DROP PROCEDURE USP_SEL_OT_ObtenReporteGeneradorMensualEncabezadoPie
GO
CREATE PROCEDURE [dbo].[USP_SEL_OT_ObtenReporteGeneradorMensualEncabezadoPie]
    @ContratoId     INT,
    @UsuarioId     INT,
    @Mes           DATE,
    @OTSolicitudId INT 
AS
    BEGIN
        SET NOCOUNT ON
		DECLARE @TempDatos TABLE (
			 Subcontratista VARCHAR(1500),
			 Proveedor VARCHAR(1500),
			 Folio VARCHAR(1500),
			 ProyectoObra VARCHAR(1500),
			 Estimacion VARCHAR(1500),
			 EmbarcacionSitio VARCHAR(1500),
			 EsRentaEquipo BIT,
			 EsFletamento BIT,
			 EsServicios BIT,
			 NumeroPedido VARCHAR(1500),
			 Nota VARCHAR(1500),
			 NombreElaboro VARCHAR(1500),
			 Logo Image,
			 NombreMesAnio VARCHAR(100),
			 CantidadDiasMes INT,
			 Dia29 INT NULL,
			 Dia30 INT NULL,
			 Dia31 INT NULL,
			 Documento VARCHAR(150)
		);

		INSERT INTO @TempDatos(Subcontratista,
			 Proveedor,
			 Folio,
			 ProyectoObra,
			 Estimacion,
			 EmbarcacionSitio,
			 EsRentaEquipo ,
			 EsFletamento,
			 EsServicios ,
			 NumeroPedido,
			 Nota,
			 NombreElaboro,
			 Logo,
			 NombreMesAnio,
			 CantidadDiasMes,
			 Documento)
		SELECT 
			CO_Contratista.RazonSocial,
			PV_Subcontratista.RazonSocial,
			OT_Solicitud.Folio,
			'',
			'',
			'',
			0,
			0,
			1,
			SC_Subcontrato.NumeroSubContrato,
			OT_Solicitud.Notas,
			AP_Usuario.Nombre,
			CO_Contratista.Logo,
			UPPER(FORMAT(@Mes, 'MMMM - yyyy', 'es-ES')),
			DAY(EOMONTH(@Mes)),
			'PAB.009.FO.05.R2'
		FROM  
			OT_Solicitud  (NOLOCK)
		JOIN
			SC_Subcontrato  (NOLOCK)
        ON 
			OT_Solicitud.IdOTSolicitud = @OTSolicitudId
               AND OT_Solicitud.IdSubContrato = SC_Subcontrato.IdSubcontrato
        JOIN 
			PV_Subcontratista  (NOLOCK)
        ON 
			SC_Subcontrato.IdSubContratista = PV_Subcontratista.IdSubcontratista
		JOIN 
			CO_Contratista  (NOLOCK)
        ON 
			SC_Subcontrato.IdContratista = CO_Contratista.IdContratista
		JOIN
			AP_Usuario  (NOLOCK)
			ON AP_Usuario.UsuarioId = @UsuarioId
		WHERE 
			OT_Solicitud.IdOTSolicitud = @OTSolicitudId;

		UPDATE @TempDatos 
		SET DIA29 = CASE 
			WHEN CantidadDiasMes >= 29
			THEN 29
			END,
		 DIA30 = CASE 
			WHEN CantidadDiasMes >= 30
			THEN 30
			END,
		DIA31 = CASE 
			WHEN CantidadDiasMes = 31
			THEN 31
			END
		 
		SELECT * FROM @TempDatos;

    END;

	
