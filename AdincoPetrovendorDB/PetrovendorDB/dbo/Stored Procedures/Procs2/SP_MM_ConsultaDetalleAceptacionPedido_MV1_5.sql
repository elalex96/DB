
-- =============================================
-- Author: Daniel AC
-- Create date: 05-01-2021
-- Description: Se agrego infromación del yacimiento en la descripción del material
-- =============================================

CREATE PROCEDURE [dbo].[SP_MM_ConsultaDetalleAceptacionPedido_MV1_5] --442
@IdAceptacionPedido INT, 
@IdContrato         INT      = NULL, 
@IdUsuario          INT      = NULL, 
@FechaRegistro      DATETIME = NULL
AS
    BEGIN
        DECLARE @LineasPresupuesto TABLE
        (IdLineaPresupuesto INT, 
         IdActividad        NVARCHAR(MAX), 
         Actividad          NVARCHAR(MAX), 
         IdSubActividad     NVARCHAR(MAX), 
         SubActividad       NVARCHAR(MAX), 
         IdTarea            NVARCHAR(MAX), 
         Tarea              NVARCHAR(MAX), 
         IdServicio         NVARCHAR(MAX), 
         Servicio           NVARCHAR(MAX), 
         IdPresupuesto      NVARCHAR(MAX), 
         NombrePresupuesto  NVARCHAR(MAX), 
         AC_PRESUP_MES      DATE
        );

        DECLARE @LineaPresupuesto NVARCHAR(MAX), @IdPedido INT;

        SELECT @IdPedido = IdPedido
        FROM dbo.MM_AceptacionPedido
        WHERE IdAceptacionPedido = @IdAceptacionPedido;


        INSERT INTO @LineasPresupuesto
        (IdLineaPresupuesto, 
         IdActividad, 
         Actividad, 
         IdSubActividad, 
         SubActividad, 
         IdTarea, 
         Tarea, 
         IdServicio, 
         Servicio, 
         IdPresupuesto, 
         NombrePresupuesto, 
         AC_PRESUP_MES
        )
               SELECT TOP 1 lpm.IdLineaPresupuestoMes, 
                            a.id_Actividad, 
                            a.DescripcionActividadPetrolera, 
                            sb.[id_Sub-actividad], 
                            sb.SubactividadPetrolera, 
                            tp.id_Tarea, 
                            tp.TareaPetrolera, 
                            s.IdServicio, 
                            s.NombreServicio, 
                            PRS.IdPresupuesto, 
                            PRS.Nombre AS NombrePresupuesto, 
                            lpm.AC_PRESUP_MES
               FROM dbo.MM_SolicitudPedido AS SP
                    LEFT JOIN dbo.MM_SolicitudPedidoDetalle AS SPD ON SPD.IdSolicitudPedido = SP.IdSolicitudPedido
                    LEFT JOIN dbo.MM_Pedido AS P ON P.IdSolicitudPedido = SP.IdSolicitudPedido
                    LEFT JOIN dbo.MM_SolicitudPedidoDetalleLineaPresupuesto AS SPDLP ON SPDLP.IdSolicitudPedidoDetalle = SPD.IdSolicitudPedidoDetalle
                    LEFT JOIN Adinco.dbo.CO_LineaPresupuestoMes lpm ON spdlp.IdLineaPresupuesto = lpm.IdLineaPresupuestoMes
                    LEFT JOIN Adinco.dbo.CO_ActividadPetroleraCNH a ON a.IdActividadPetrolera = lpm.IdActividadPetrolera
                    LEFT JOIN adinco.dbo.CO_SubactividadPetrolera sb ON sb.IdSubactividadPetrolera = lpm.IdSubactividadPetrolera
                    LEFT JOIN Adinco.dbo.CO_TareaPetrolera tp ON tp.IdTareaPetrolera = lpm.IdTareaPetrolera
                    LEFT JOIN Adinco.dbo.CO_Servicio s ON s.IdServicio = lpm.IdServicio
                    LEFT JOIN Adinco.dbo.CO_Presupuesto AS PRS ON PRS.IdPresupuesto = lpm.IdPresupuesto

               WHERE P.IdPedido = @IdPedido;

        SELECT @LineaPresupuesto = CONCAT(NombrePresupuesto, ' | ', 'Mes Programado: ', RIGHT('00' + LTRIM(MONTH(AC_PRESUP_MES)), 2), ' ', dbo.Fn_RetornarMesEspanol(MONTH(AC_PRESUP_MES)), ' ', YEAR(AC_PRESUP_MES), ' | ', IdActividad, ' | ', Actividad, ' | ', IdSubActividad, ' | ', SubActividad, ' | ', IdTarea, ' | ', Tarea, ' | ', IdServicio, ' | ', Servicio)
        FROM @LineasPresupuesto;
       

	    SELECT M.IdMaterial, 
               CONCAT(POD.MaterialCotizadoTextoC, ' Descripción: ', POD.MaterialCotizadoTextoL) AS DescripcionCorta, 
               U.Unidad AS NombreUnidad, 
               CONCAT(APD.Cantidad, ' / ', APD.Excedente) AS Cantidad, 
               CONCAT((CASE
                           WHEN LEN(APD.Detalle) > 0
                           THEN CONCAT(APD.Detalle, ' | ')
                           ELSE ' '
                       END), ISNULL('Instalación: ' + INS.NombreInstalacion COLLATE Modern_Spanish_CI_AS, ' '),ISNULL(' | Yacimiento: ' + Y.NombreYacimiento COLLATE Modern_Spanish_CI_AS, ' '), ' | ', ISNULL(@LineaPresupuesto, ' ')) AS Detalle
        FROM MM_AceptacionPedidoDetalle AS APD
             LEFT JOIN MM_AceptacionPedido AS AP ON AP.IdAceptacionPedido = APD.IdAceptacionPedido
             LEFT JOIN dbo.MM_Pedido P ON P.IdPedido = AP.IdPedido
             LEFT JOIN MM_PedidoDetalle AS PD ON PD.IdPedidoDetalle = APD.IdPedidoDetalle
                                                 AND P.IdPedido = PD.IdPedido
             LEFT JOIN dbo.MM_PeticionOferta PO ON PO.IdPeticionOferta = P.IdPeticionOferta
             LEFT JOIN dbo.MM_PeticionOfertaDetalle POD ON POD.IdPeticionOferta = PO.IdPeticionOferta
                                                           AND POD.IdPeticionOfertaDetalle = PD.IdPeticionOfertaDetalle
             LEFT JOIN MM_Material AS M ON M.IdMaterial = PD.IdMaterialVendedor
             LEFT JOIN PV_MM_MaterialUnidad AS U ON U.IdUnidad = M.IdUnidad
             LEFT JOIN dbo.MM_AceptacionPedidoDetalleInstalacion AS APDI ON APDI.IdAceptacionPedido = AP.IdAceptacionPedido
                                                                            AND APDI.IdAceptacionPedidoDetalle = APD.IdAceptacionPedidoDetalle
             LEFT JOIN Adinco.dbo.CO_Instalacion AS INS ON INS.IdInstalacion = APDI.IdInstalacion
             LEFT JOIN Adinco.dbo.CO_LineaPresupuestoMes AS lp ON lp.IdLineaPresupuestoMes = APDI.IdLineaPresupuesto
			 LEFT JOIN Adinco..CO_Yacimiento Y ON INS.IdYacimiento=Y.IdYacimiento
        WHERE AP.IdAceptacionPedido = @IdAceptacionPedido;
    END;
