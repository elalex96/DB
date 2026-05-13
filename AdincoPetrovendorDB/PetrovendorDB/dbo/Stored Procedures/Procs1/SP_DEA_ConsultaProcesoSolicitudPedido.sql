-- =============================================
-- Author:		<Alexander Gomez>
-- Create date: <18/05/2020>
-- Description:	<Cosnulta de proceso de solicitud de pedido>
-- =============================================
CREATE PROCEDURE [dbo].[SP_DEA_ConsultaProcesoSolicitudPedido]
	-- Add the parameters for the stored procedure here
	@IDCONTRATO INT = NULL
AS
BEGIN
	-- SET NOCOUNT ON added to prevent extra result sets from
	-- interfering with SELECT statements.
	SET NOCOUNT ON;

                            

DECLARE @DATOSSOLPEDFIN TABLE(
                            IdSolicitudPedido INT, 
                            Folio NVARCHAR(100),
                            Descripcion NVARCHAR(MAX), 
                            CentroCosto NVARCHAR(MAX), 
                            Requisitor NVARCHAR(MAX), 
                            FechaRegistro DATETIME, 
                            Responsable1aAprobacion NVARCHAR(MAX),
                            Fecha1aAprobacion DATETIME,
                            Estatus1aAprobacion NVARCHAR(MAX),
							Dias1apro NVARCHAR(100),
                            ResponsableReasignado NVARCHAR(MAX),
                            FechaAprobacionReasignado DATETIME,
                            EstatusAprobacionReasignado NVARCHAR(MAX),
							Dias1asig NVARCHAR(100),
                            Responsable2aAprobacion NVARCHAR(MAX),
                            Fecha2aAprobacion DATETIME,
                            Estatus2aAprobacion NVARCHAR(MAX),
							Dias2aprob NVARCHAR(100),
							Responsable2daReasigacion NVARCHAR(MAX),
                            FechaAprobacion2daReasignacion DATETIME,
                            EstatusAprobacion2daReasignacion NVARCHAR(MAX),
							Dias2aprobreasig NVARCHAR(100),
                            UsuarioCargaPR NVARCHAR(MAX),
                            FechaCargaPR DATETIME,
                            NumeroPR NVARCHAR(100),
							DiasCargaPR NVARCHAR(100),
							DiasAprobGral NVARCHAR(100),
                            EstatusFinal NVARCHAR(100),
                            FechaRegistroTareaReasignado DATETIME
                            );

SELECT
	IdSolicitudPedido AS IdSolicitudPedido,
	Folio AS Folio,
	Descripcion AS Descripcion,
	CentroCosto AS CentroCosto,
	Requisitor AS Requisitor,
	FechaRegistro AS FechaRegistro,
	REPLACE(Responsable1aAprobacion,'()','') AS Responsable1aAprobacion,
	Fecha1aAprobacion AS Fecha1aAprobacion,
	CASE
		WHEN Estatus1aAprobacion = 'En Aprobación' OR Estatus1aAprobacion IS NULL THEN NULL
		ELSE ISNULL(CONVERT(DECIMAL(5,2),Dias1apro),0)
	END AS DiasEspera1aAprobacion,
	ISNULL(Estatus1aAprobacion,'') AS Estatus1aAprobacion,
	ISNULL(ResponsableReasignado,'') AS Responsable1aReasignacion,
	FechaAprobacionReasignado AS FechaAprobacionReasignado,
	CASE
		WHEN EstatusAprobacionReasignado = 'En Aprobación' OR EstatusAprobacionReasignado IS NULL THEN NULL
		ELSE ISNULL(CONVERT(DECIMAL(5,2),Dias1asig),0.00)
	END AS DiasEspera1aReasignacion,
	EstatusAprobacionReasignado AS EstatusAprobacion1aReasignacion,
	CASE
		WHEN Estatus1aAprobacion = 'Rechazada' OR EstatusAprobacionReasignado = 'Rechazada' THEN NULL
		ELSE Responsable2aAprobacion
	END AS Responsable2aAprobacion,
	CASE 
		WHEN Fecha2aAprobacion IS NULL THEN NULL
		WHEN Estatus1aAprobacion = 'Rechazada' OR EstatusAprobacionReasignado = 'Rechazada' THEN NULL
		ELSE Fecha2aAprobacion
	END AS Fecha2aAprobacion,
	CASE
		WHEN Estatus2aAprobacion = 'En Aprobación' OR Estatus2aAprobacion IS NULL THEN NULL
		WHEN Estatus1aAprobacion = 'Rechazada' OR EstatusAprobacionReasignado = 'Rechazada' THEN NULL
		ELSE ISNULL(CONVERT(DECIMAL(5,2),Dias2aprob),0.00)
	END AS DiasEspera2aAprobacion,
	CASE
		WHEN Estatus2aAprobacion = 'Cancelado por Rechazo' THEN NULL
		ELSE Estatus2aAprobacion
	END AS Estatus2aAprobacion,
	Responsable2daReasigacion AS Responsable2aReasignacion,
	FechaAprobacion2daReasignacion AS FechaAprobacion2daReasignacion,
	CASE
		WHEN EstatusAprobacion2daReasignacion = 'En Aprobación' OR EstatusAprobacion2daReasignacion IS NULL THEN NULL
		ELSE ISNULL(CONVERT(DECIMAL(5,2),Dias2aprobreasig),0.00)
	END AS DiasEspera2aReasignacion,
	EstatusAprobacion2daReasignacion AS EstatusAprobacion2aReasignacion,
	ISNULL(CONVERT(DECIMAL(5,2),DiasAprobGral),0.00) AS DiasEnAprobacionGeneral,
	UsuarioCargaPR AS UsuarioCargaPR,
	FechaCargaPR AS FechaCargaPR,
	CASE
		WHEN UsuarioCargaPR IS NULL THEN NULL
		ELSE ISNULL(CONVERT(DECIMAL(5,2),DiasCargaPR),0.00)
	END AS DiasCargaPR,
	NumeroPR AS NumeroPR,
	ISNULL(CONVERT(DECIMAL(5,2),DiasAprobGral),0.00) + ISNULL(CONVERT(DECIMAL(5,2),DiasCargaPR),0.00) AS DiasTotal,
	EstatusFinal AS EstatusFinal
FROM @DATOSSOLPEDFIN
ORDER BY IdSolicitudPedido DESC;


END
