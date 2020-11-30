CREATE VIEW dbo.JOA_ShellFacts_Especial
AS

SELECT
	Contrato,
	AreaBOM,
	Category,
	COOWNER,
	NombreObligacion,
	Funcion,
	Usuario,
	CorreoUsuario,
	Rol,
	Status,
	AccountableCompliance,
	AccountableComplianceEmail,
	Accountable,
	AccountableEmail,
	DiasAtraso,
	ContractName,
	Deadline,
	FechaConfirmacion,
	ID,
	Topic,
	Clause,
	Articulo,
	Actividad,
	Proceso,
	Orden,
	DeliverableName
FROM
	JOA_ShellFacts
UNION
SELECT
	Contrato,
	AreaBOM,
	Category,
	COOWNER,
	NombreObligacion,
	Funcion,
	AccountableCompliance	AS Usuario,
	AccountableComplianceEmail	AS CorreoUsuario,
	'AccountableCompliance'	AS	Rol,
	Status,
	AccountableCompliance,
	AccountableComplianceEmail,
	Accountable,
	AccountableEmail,
	DiasAtraso,
	ContractName,
	Deadline,
	FechaConfirmacion,
	ID,
	Topic,
	Clause,
	Articulo,
	Actividad,
	Proceso,
	Orden,
	DeliverableName
FROM
	JOA_ShellFacts
WHERE
	AccountableCompliance <> ''
UNION
SELECT
	Contrato,
	AreaBOM,
	Category,
	COOWNER,
	NombreObligacion,
	Funcion,
	Accountable	AS Usuario,
	AccountableEmail	AS CorreoUsuario,
	'Accountable'	AS	Rol,
	Status,
	AccountableCompliance,
	AccountableComplianceEmail,
	Accountable,
	AccountableEmail,
	DiasAtraso,
	ContractName,
	Deadline,
	FechaConfirmacion,
	ID,
	Topic,
	Clause,
	Articulo,
	Actividad,
	Proceso,
	Orden,
	DeliverableName
FROM
	JOA_ShellFacts
WHERE
	Accountable <> ''