use Petrovendor
go
drop proc if exists SP_TA_ValidarTipoUsuarioSolicitud
go
-- =============================================
-- Author:		Daniel A Cruz
-- Create date: 13-09-2017
-- Description:	VALIDAR SI EL USUARIO ES APROBADOR O ASIGNADOR
-- =============================================
USE Petrovendor
GO

DROP PROCEDURE IF EXISTS SP_TA_ValidarTipoUsuarioSolicitud
GO

-- =============================================
-- Author:		Daniel A Cruz
-- Create date: 13-09-2017
-- Description:	VALIDAR SI EL USUARIO ES APROBADOR O ASIGNADOR
-- =============================================
-- Author:		David
-- Create date: marzo 31 24
-- Description:	Se optimiza sp Issue #2686 petrovendor
-- =============================================
CREATE PROCEDURE [dbo].[SP_TA_ValidarTipoUsuarioSolicitud] 
    -- Add the parameters for the stored procedure here
    @IdUsuario int, 
    @IdTipoAprobador int,
    @IdSolicitudPedido int 
AS
BEGIN
    -- SET NOCOUNT ON added to prevent extra result sets from
    -- interfering SELECT statements.
    SET NOCOUNT ON;

    DECLARE @RESPONSE NVARCHAR(300) = 'NO_APROBADOR_NO_ASIGNADOR';

    -- Insert statements for procedure here
    IF @IdTipoAprobador = '2'  ---ASIGNADOR
    BEGIN 
        SELECT 
            CASE  
                WHEN COUNT(O.IdDocumento) > 0 THEN 'ES_ASIGNADOR'  
                ELSE 'NO_APROBADOR_NO_ASIGNADOR' 
            END 
        FROM 
            TA_Operacion AS O (NOLOCK)
        INNER JOIN 
            MM_SolicitudPedido AS SP (NOLOCK) ON O.IdDocumento = SP.IdSolicitudPedido
        WHERE 
            O.IdDocumento = @IdSolicitudPedido 
            AND O.IdAsignador = @IdUsuario 
            AND O.IdTipoOperacion = 2;
    END 

    IF @IdTipoAprobador = '1'  --APROBADOR
    BEGIN 
        SELECT 
            CASE  
                WHEN COUNT(O.IdDocumento) > 0 THEN 'ES_APROBADOR'   
                ELSE 'NO_APROBADOR_NO_ASIGNADOR' 
            END 
        FROM 
            TA_Operacion AS O (NOLOCK)
        INNER JOIN 
            MM_SolicitudPedido AS SP (NOLOCK) ON O.IdDocumento = SP.IdSolicitudPedido
        INNER JOIN 
            TA_TareaOperacion AS TAO (NOLOCK) ON O.IdOperacion = TAO.IdOperacion
        LEFT JOIN 
            TA_Tarea AS TA (NOLOCK) ON TAO.IdTarea = TA.IdTarea
        WHERE 
            O.IdDocumento = @IdSolicitudPedido 
            AND TA.IdAprobador = @IdUsuario 
            AND O.IdTipoOperacion = 2;
    END 
END
