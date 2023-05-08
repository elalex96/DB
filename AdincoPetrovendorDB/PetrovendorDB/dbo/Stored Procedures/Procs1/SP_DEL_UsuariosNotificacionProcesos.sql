-- =============================================
-- Author:		<Alexander Gomez>
-- Create date: <10-07-2019>
-- Description:	<Consulta de usuarios responsables para la eliminacion de procesos>
-- =============================================
CREATE PROCEDURE [dbo].[SP_DEL_UsuariosNotificacionProcesos] --18648, 1
	-- Add the parameters for the stored procedure here
	@IdProceso INT,
	@IdTipoProceso INT
AS
BEGIN
	-- SET NOCOUNT ON added to prevent extra result sets from
	-- interfering with SELECT statements.
	SET NOCOUNT ON;

    -- Insert statements for procedure here

	CREATE TABLE #USUARIOS(
		IdProceso INT,
		IdUsuario INT,
		Nombre NVARCHAR(MAX),
		Correo NVARCHAR(MAX),
		Operadora NVARCHAR(MAX),
		Contrato NVARCHAR(MAX),
		Proveedor NVARCHAR(MAX)
	);

	DECLARE @RFCPROCESO NVARCHAR(MAX);


	--SOLICICTUD PEDIDO
	IF @IdTipoProceso = 1
	BEGIN

		SET @RFCPROCESO = (SELECT TOP 1 PR.RFC
							FROM dbo.MM_SolicitudPedido AS SP
							LEFT JOIN dbo.S_Proveedor AS PR ON PR.IdProveedor = SP.IdProveedor
							WHERE SP.IdSolicitudPedido = @IdProceso);

		IF @RFCPROCESO = 'PEP170906DI5' OR @RFCPROCESO = 'JEP1709042B1'
		BEGIN
		    
		
			--REQUISITOR
			INSERT INTO #USUARIOS
			SELECT
				SP.IdSolicitudPedido,
				US.IdUsuario,
				US.Nombre,
				US.Correo,
				PR.RazonSocial,
				ISNULL(C.NumeroContrato,'') + ' - ' + AC.NombreAreaContractual,
				''
			FROM dbo.MM_SolicitudPedido AS SP
				LEFT JOIN dbo.S_Usuario AS US ON US.IdUsuario = SP.IdUsuarioSolicitante
				LEFT JOIN dbo.S_Proveedor AS PR ON PR.IdProveedor = SP.IdProveedor
				LEFT JOIN Adinco.dbo.CO_Contrato AS C ON C.IdContrato = SP.IdContrato
				LEFT JOIN Adinco.dbo.CO_AreaContractual AS AC ON AC.IdAreaContractual = C.IdAreaContractual
			WHERE SP.IdSolicitudPedido = @IdProceso AND US.Activo = 1
			GROUP BY ISNULL(C.NumeroContrato, '') + ' - ' + AC.NombreAreaContractual,
                     SP.IdSolicitudPedido,
                     US.IdUsuario,
                     US.Nombre,
                     US.Correo,
                     PR.RazonSocial;
		
			--Fernando  Dominguez,Gabriela Garcia
			INSERT INTO #USUARIOS
			SELECT
				SP.IdSolicitudPedido,
				USP.IdUsuario,
				USP.Nombre,
				USP.Correo,
				PR.RazonSocial,
				ISNULL(C.NumeroContrato,'') + ' - ' + AC.NombreAreaContractual,
				''
			FROM dbo.MM_SolicitudPedido AS SP
				LEFT JOIN dbo.S_Proveedor AS PR ON PR.IdProveedor = SP.IdProveedor
				LEFT JOIN dbo.S_UsuarioProveedor AS USPR ON USPR.IdProveedor = PR.IdProveedor
				LEFT JOIN dbo.S_Usuario AS USP ON USP.IdUsuario = USPR.IdUsuario
				LEFT JOIN Adinco.dbo.CO_Contrato AS C ON C.IdContrato = SP.IdContrato
				LEFT JOIN Adinco.dbo.CO_AreaContractual AS AC ON AC.IdAreaContractual = C.IdAreaContractual
			WHERE SP.IdSolicitudPedido = @IdProceso AND USP.IdUsuario IN (4210,2479) AND USP.Activo = 1
			GROUP BY ISNULL(C.NumeroContrato, '') + ' - ' + AC.NombreAreaContractual,
                     SP.IdSolicitudPedido,
                     USP.IdUsuario,
                     USP.Nombre,
                     USP.Correo,
                     PR.RazonSocial;

			--todo finanza excepto 3117
			INSERT INTO #USUARIOS
			SELECT
				SP.IdSolicitudPedido,
				USP.IdUsuario,
				USP.Nombre,
				USP.Correo,
				PR.RazonSocial,
				ISNULL(C.NumeroContrato,'') + ' - ' + AC.NombreAreaContractual,
				''
			FROM dbo.MM_SolicitudPedido AS SP
				LEFT JOIN dbo.S_Proveedor AS PR ON PR.IdProveedor = SP.IdProveedor
				LEFT JOIN dbo.S_UsuarioProveedor AS USPR ON USPR.IdProveedor = PR.IdProveedor
				LEFT JOIN dbo.S_Usuario AS USP ON USP.IdUsuario = USPR.IdUsuario
				LEFT JOIN Adinco.dbo.CO_Contrato AS C ON C.IdContrato = SP.IdContrato
				LEFT JOIN Adinco.dbo.CO_AreaContractual AS AC ON AC.IdAreaContractual = C.IdAreaContractual
			WHERE SP.IdSolicitudPedido = @IdProceso AND USP.IdTipoUsuario = 6 AND USP.Activo = 1 AND USP.IdUsuario != 3171
			GROUP BY ISNULL(C.NumeroContrato, '') + ' - ' + AC.NombreAreaContractual,
                     SP.IdSolicitudPedido,
                     USP.IdUsuario,
                     USP.Nombre,
                     USP.Correo,
                     PR.RazonSocial;
			END;
	END;

	

	--PERDIDO
	IF @IdTipoProceso = 2
	BEGIN
		
		SET @RFCPROCESO = (
		SELECT TOP 1
			OP.RFC
		FROM dbo.MM_Pedido AS P
			LEFT JOIN dbo.S_Proveedor AS OP ON OP.IdProveedor = P.IdProveedorCompras
		WHERE P.IdPedido = @IdProceso);

		IF @RFCPROCESO = 'PEP170906DI5' OR @RFCPROCESO = 'JEP1709042B1'
		BEGIN

	    INSERT INTO #USUARIOS
		SELECT
			PS.IdPedido,
			US.IdUsuario,
			US.Nombre,
			US.Correo,
			PR.RazonSocial,
			ISNULL(C.NumeroContrato,'') + ' - ' + AC.NombreAreaContractual,
			OP.RazonSocial
		FROM dbo.MM_Pedido AS P
			LEFT JOIN dbo.S_Proveedor AS OP ON OP.IdProveedor = P.IdProveedorCompras
			LEFT JOIN dbo.MM_Pedidos AS PS ON PS.IdIdentificador = P.IdPedido
			LEFT JOIN dbo.S_Proveedor AS PR ON PR.IdProveedor = P.IdSubcontratista
			LEFT JOIN dbo.S_Usuario AS US ON US.IdUsuario = P.CreadoPor
			LEFT JOIN dbo.MM_SolicitudPedido AS SP ON SP.IdSolicitudPedido = P.IdSolicitudPedido
			LEFT JOIN Adinco.dbo.CO_Contrato AS C ON C.IdContrato = SP.IdContrato
			LEFT JOIN Adinco.dbo.CO_AreaContractual AS AC ON AC.IdAreaContractual = C.IdAreaContractual
		WHERE P.IdPedido = @IdProceso AND US.Activo = 1
		GROUP BY PS.IdPedido,
			US.IdUsuario,
			US.Nombre,
			US.Correo,
			PR.RazonSocial,
			ISNULL(C.NumeroContrato,'') + ' - ' + AC.NombreAreaContractual,
			OP.RazonSocial;

		INSERT INTO #USUARIOS
		SELECT
			PS.IdPedido,
			US.IdUsuario,
			US.Nombre,
			US.Correo,
			OP.RazonSocial,
			ISNULL(C.NumeroContrato,'') + ' - ' + AC.NombreAreaContractual,
			PR.RazonSocial
		FROM dbo.MM_Pedido AS P
			LEFT JOIN dbo.S_Proveedor AS OP ON OP.IdProveedor = P.IdProveedorCompras
			LEFT JOIN dbo.MM_Pedidos AS PS ON PS.IdIdentificador = P.IdPedido
			LEFT JOIN dbo.S_Proveedor AS PR ON PR.IdProveedor = P.IdSubcontratista
			LEFT JOIN dbo.S_UsuarioProveedor AS USPR ON USPR.IdProveedor = P.IdProveedorCompras
			LEFT JOIN dbo.S_Usuario AS US ON US.IdUsuario = USPR.IdUsuario
			LEFT JOIN dbo.MM_SolicitudPedido AS SP ON SP.IdSolicitudPedido = P.IdSolicitudPedido
			LEFT JOIN Adinco.dbo.CO_Contrato AS C ON C.IdContrato = SP.IdContrato
			LEFT JOIN Adinco.dbo.CO_AreaContractual AS AC ON AC.IdAreaContractual = C.IdAreaContractual
		WHERE P.IdPedido = @IdProceso AND US.IdUsuario IN (4210,2479) AND US.Activo = 1
		GROUP BY PS.IdPedido,
			US.IdUsuario,
			US.Nombre,
			US.Correo,
			PR.RazonSocial,
			ISNULL(C.NumeroContrato,'') + ' - ' + AC.NombreAreaContractual,
			OP.RazonSocial;

		INSERT INTO #USUARIOS
		SELECT
			PS.IdPedido,
			US.IdUsuario,
			US.Nombre,
			US.Correo,
			OP.RazonSocial,
			ISNULL(C.NumeroContrato,'') + ' - ' + AC.NombreAreaContractual,
			PR.RazonSocial
		FROM dbo.MM_Pedido AS P
			LEFT JOIN dbo.S_Proveedor AS OP ON OP.IdProveedor = P.IdProveedorCompras
			LEFT JOIN dbo.MM_Pedidos AS PS ON PS.IdIdentificador = P.IdPedido
			LEFT JOIN dbo.S_Proveedor AS PR ON PR.IdProveedor = P.IdSubcontratista
			LEFT JOIN dbo.S_UsuarioProveedor AS USPR ON USPR.IdProveedor = P.IdProveedorCompras
			LEFT JOIN dbo.S_Usuario AS US ON US.IdUsuario = USPR.IdUsuario
			LEFT JOIN dbo.MM_SolicitudPedido AS SP ON SP.IdSolicitudPedido = P.IdSolicitudPedido
			LEFT JOIN Adinco.dbo.CO_Contrato AS C ON C.IdContrato = SP.IdContrato
			LEFT JOIN Adinco.dbo.CO_AreaContractual AS AC ON AC.IdAreaContractual = C.IdAreaContractual
		WHERE P.IdPedido = @IdProceso AND US.IdTipoUsuario IN (6) AND US.Activo = 1 AND US.IdUsuario != 3171
		GROUP BY PS.IdPedido,
			US.IdUsuario,
			US.Nombre,
			US.Correo,
			PR.RazonSocial,
			ISNULL(C.NumeroContrato,'') + ' - ' + AC.NombreAreaContractual,
			OP.RazonSocial;

		END;

	END;

	SELECT * FROM #USUARIOS

END
