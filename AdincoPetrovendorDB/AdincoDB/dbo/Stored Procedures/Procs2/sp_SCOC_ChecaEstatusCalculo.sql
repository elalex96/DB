
-- =============================================
-- Author:		Reyna Olvera
-- Create date: 21/09/2018
-- Description:	Checa estus de calculo mes, para habilitar o deshabilitar carga
-- =============================================
CREATE PROCEDURE [dbo].[sp_SCOC_ChecaEstatusCalculo] --10010,'20180901'
    @idContrato INT,
    @FechaReporte DATE,
    @IdUsuario INT = 0
AS
BEGIN

    SET NOCOUNT ON;
    DECLARE @count INT;
    DECLARE @Estatus INT,
            @IsPC    INT;

    SELECT @count = COUNT(*)
      FROM SCOC_EnvioNotificacion
     WHERE idContrato = @idContrato
       AND MesReporte = @FechaReporte;
    
    SELECT @IsPC=
           CASE CO_Contrato.IdTipoContrato
               WHEN 2 THEN
                  CO_Contrato.IdTipoContrato
               WHEN 3 THEN
                   CASE IsConsorcio
                       WHEN 0 THEN
                           IsConsorcio
                       ELSE
                           3
                   END
           END 
    FROM dbo.CO_Contrato
        JOIN dbo.CO_TipoContrato
            ON CO_TipoContrato.IdTipoContrato = CO_Contrato.IdTipoContrato
    WHERE IdContrato = @IdContrato;
 
    IF (@count > 0)
    BEGIN
        IF @IsPC <>2
        BEGIN
          
            SELECT @Estatus = 2 --Aprobado COMPLETO
              FROM SCOC_EnvioNotificacion
             WHERE idContrato = @idContrato
               AND MesReporte = @FechaReporte
               AND idEstatus  = 10005; --(AprobadoSCOC=1 AND EnviadoContratista=1 AND AprobadoRepPEP=1);


            SELECT @Estatus = 1 --En aprobacion debe aprobar PEP Primero
              FROM SCOC_EnvioNotificacion
             WHERE idContrato = @idContrato
               AND MesReporte = @FechaReporte
               AND idEstatus  = 10001; --(AprobadoSCOC=0 AND EnviadoContratista=1 AND AprobadoRepPEP=0);

            SELECT @Estatus = 0 --En elaboracion
              FROM SCOC_EnvioNotificacion
             WHERE idContrato = @idContrato
               AND MesReporte = @FechaReporte
               AND idEstatus  = 10000; --(AprobadoSCOC=0 AND EnviadoContratista=0 AND AprobadoRepPEP=0);
        END;
        ELSE IF @IsPC = 2
        BEGIN
            SELECT @Estatus = idEstatus --En Aprobación comercializador Edo. Liq.
              FROM SCOC_EnvioNotificacion
             WHERE idContrato = @idContrato
               AND MesReporte = @FechaReporte
               AND idEstatus  = 10002;

            SELECT @Estatus = idEstatus --En Aprobación Comercializador Edo. Gas
              FROM SCOC_EnvioNotificacion
             WHERE idContrato = @idContrato
               AND MesReporte = @FechaReporte
               AND idEstatus  = 10003;

			 SELECT @Estatus = idEstatus --En Aprobación Comercializadores
              FROM SCOC_EnvioNotificacion
             WHERE idContrato = @idContrato
               AND MesReporte = @FechaReporte
               AND idEstatus  = 10006;

            SELECT @Estatus = 2 --Aprobado COMPLETO
              FROM SCOC_EnvioNotificacion
             WHERE idContrato = @idContrato
               AND MesReporte = @FechaReporte
               AND idEstatus  = 10005; --(AprobadoSCOC=1 AND EnviadoContratista=1 AND AprobadoRepPEP=1);


            SELECT @Estatus = 1 --En aprobacion debe aprobar PEP Primero
              FROM SCOC_EnvioNotificacion
             WHERE idContrato = @idContrato
               AND MesReporte = @FechaReporte
               AND idEstatus  = 10001; --(AprobadoSCOC=0 AND EnviadoContratista=1 AND AprobadoRepPEP=0);

			SELECT @Estatus = 3 --En aprobacion debe aprobar PEP Primero
              FROM SCOC_EnvioNotificacion
             WHERE idContrato = @idContrato
               AND MesReporte = @FechaReporte
               AND idEstatus  = 10004; --(AprobadoSCOC=0 AND EnviadoContratista=1 AND AprobadoRepPEP=0);

            SELECT @Estatus = 0 --En elaboracion
              FROM SCOC_EnvioNotificacion
             WHERE idContrato = @idContrato
               AND MesReporte = @FechaReporte
               AND idEstatus  = 10000; --(AprobadoSCOC=0 AND EnviadoContratista=0 AND AprobadoRepPEP=0);
        END;
        SELECT @Estatus AS estatus;
    END;
    ELSE
    BEGIN
        SELECT 0 AS estatus; --En elaboracion
    END;

--10000	En Elaboración/Correción
--10001	En Aprobación PEP
--10002	En Aprobación comercializador Edo. Liq.
--10003	En Aprobación Comercializador Edo. Gas
--10004	En Aprobación SCOC
--10005	Completamente Aprobado

END;
