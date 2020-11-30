

-- =============================================
-- Author:		Pedro Acuña
-- Create date: 12/06/2019
-- Description:	Obtner la instalacion y la linea de presupuesto
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
                @IdInstalacion      = spdl.IdInstalacion,
                @IdLineaPresupuesto = spdl.IdLineaPresupuesto
        FROM
                dbo.MM_Pedido                                 p
            INNER JOIN
                dbo.MM_PedidoDetalle                          pd
                    ON pd.IdPedido = p.IdPedido
            INNER JOIN
                dbo.MM_PeticionOferta                         po
                    ON po.IdSolicitudPedido = p.IdSolicitudPedido
            INNER JOIN
                dbo.MM_PeticionOfertaDetalle                  pod
                    ON pod.IdPeticionOferta = po.IdPeticionOferta
            INNER JOIN
                dbo.MM_SolicitudPedidoDetalle                 spd
                    ON spd.IdSolicitudPedidoDetalle = pod.IdSolicitudPedidoDetalle
            INNER JOIN
                dbo.MM_SolicitudPedidoDetalleLineaPresupuesto spdl
                    ON spdl.IdSolicitudPedidoDetalle = spd.IdSolicitudPedidoDetalle
        WHERE
                p.IdProveedorCompras = @IdProveedor
                AND pd.IdPedidoDetalle = @IdPedidoDetalle
        GROUP BY
                spdl.IdInstalacion, spdl.IdLineaPresupuesto


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