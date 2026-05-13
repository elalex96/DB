USE [Petrovendor]
GO
IF EXISTS
(
    SELECT 1
    FROM dbo.sysobjects
    WHERE name = 'Sp_ObtenerLineaPresupuestoInstalacionEnAceptacionPedido'
)
    DROP PROCEDURE Sp_ObtenerLineaPresupuestoInstalacionEnAceptacionPedido;
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
-- =============================================
-- Author:		Pedro Acuña
-- Create date: 12/06/2019
-- Description:	Obtner la instalacion y la linea de presupuesto
-- =============================================
-- Author:		Alexander Gomez
-- Create date: 01/06/2023
-- Description:	correccion en la obtencion de la linea de presupuesto
-- =============================================

CREATE PROCEDURE [dbo].[Sp_ObtenerLineaPresupuestoInstalacionEnAceptacionPedido]
    @IdPedidoDetalle INT, @IdProveedor INT, @IdPresupuesto INT
AS
    BEGIN
        SET NOCOUNT ON


        DECLARE @TablaLineas TABLE ( Rw                            INT IDENTITY ,
                                     IdLineaPresupuestoMes         INT,
                                     Mes_Presupuestado             NVARCHAR (MAX),
                                     ID_TIPOSER                    NVARCHAR (MAX),
                                     CO_TipoServicio               NVARCHAR (MAX),
                                     ID_CATACTIV                   NVARCHAR (MAX),
                                     Actividad                     NVARCHAR (MAX),
                                     ID_CATSUBACTIV                NVARCHAR (MAX),
                                     SubActividad                  NVARCHAR (MAX),
                                     Servicio                      NVARCHAR (MAX),
                                     Instalacion                   NVARCHAR (MAX),
                                     Presupuesto_USD               NVARCHAR (MAX),
                                     ID                            INT,
                                     id_Actividad                  NVARCHAR (MAX),
                                     DescripcionActividadPetrolera NVARCHAR (MAX),
                                     [id_Sub-actividad]            NVARCHAR (MAX),
                                     SubactividadPetrolera         NVARCHAR (MAX),
                                     id_Tarea                      NVARCHAR (MAX),
                                     TareaPetrolera                NVARCHAR (MAX),
                                     fila                          INT,
                                     MontoEjercido                 NVARCHAR (MAX),
                                     Remanente                     NVARCHAR (MAX),
                                     PorcentajeUsado               NVARCHAR (MAX))


        DECLARE
            @IdInstalacion      INT,
            @IdLineaPresupuesto INT,
            @RowNumber          INT,
            @CantidadLineas     INT


        INSERT INTO
            @TablaLineas ( IdLineaPresupuestoMes,
                           Mes_Presupuestado,
                           ID_TIPOSER,
                           CO_TipoServicio,
                           ID_CATACTIV,
                           Actividad,
                           ID_CATSUBACTIV,
                           SubActividad,
                           Servicio,
                           Instalacion,
                           Presupuesto_USD,
                           ID,
                           id_Actividad,
                           DescripcionActividadPetrolera,
                           [id_Sub-actividad],
                           SubactividadPetrolera,
                           id_Tarea,
                           TareaPetrolera,
                           fila,
                           MontoEjercido,
                           Remanente,
                           PorcentajeUsado )
        EXEC dbo.CO_SP_ConsultaLineaPresupuestoMesv2
        @presupuesto = @IdPresupuesto


        SELECT @CantidadLineas = COUNT(1) FROM @TablaLineas

		SELECT
			@IdInstalacion = SPDLP.IdInstalacion,
			@IdLineaPresupuesto = SPDLP.IdLineaPresupuesto
		FROM dbo.MM_PedidoDetalle AS PD (NOLOCK)
			JOIN dbo.MM_PeticionOfertaDetalle AS POD (NOLOCK)
				ON PD.IdPedidoDetalle = @IdPedidoDetalle
				AND PD.IdPeticionOfertaDetalle = POD.IdPeticionOfertaDetalle
			JOIN dbo.MM_SolicitudPedidoDetalle AS SPD (NOLOCK)
				ON POD.IdSolicitudPedidoDetalle = SPD.IdSolicitudPedidoDetalle
			JOIN MM_SolicitudPedidoDetalleLineaPresupuesto AS SPDLP (NOLOCK)
				ON SPD.IdSolicitudPedidoDetalle = SPDLP.IdSolicitudPedidoDetalle
		GROUP BY SPDLP.IdInstalacion,
				SPDLP.IdLineaPresupuesto;


        SELECT @RowNumber = ISNULL(Rw, 0)
        FROM
               @TablaLineas
        WHERE
               IdLineaPresupuestoMes = @IdLineaPresupuesto


        SELECT
            @IdInstalacion         AS IdInstalacion,
            @IdLineaPresupuesto    AS IdLineaPresupuesto,
            ISNULL(@RowNumber, 0)             AS RowNumber,
            ISNULL(@CantidadLineas, 0)        AS CantidadLineas,
            ISNULL( @RowNumber / 6 , 0) AS Pagina
    END