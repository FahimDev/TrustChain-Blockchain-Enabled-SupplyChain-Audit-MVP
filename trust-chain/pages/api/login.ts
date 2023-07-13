// Next.js API route support: https://nextjs.org/docs/api-routes/introduction
import type { NextApiRequest, NextApiResponse } from "next";
import jwt from "jsonwebtoken";

type Data = {
  id: string;
  username: string;
  token: string;
  loginAttemptAt: string;
};

const KEY = "60aa317d8b4221dd66cb57717d547ba590dcf567a354e89379aaddabe259057d";

/**
 * @swagger
 * /api/login:
 *   post:
 *     tags: [Login]
 *     description: Returns  Token
 *     requestBody:
 *       required: true
 *       content:
 *         application/json:
 *           schema:
 *             $ref: '#/definitions/User'     # <----------
 *     responses:
 *       200:
 *         description: JWT Token
 *         content:
 *           application/json:
 *             schema:
 *               type: object
 *               $ref: '#/components/schemas/Login'
 *
 * definitions:
 *   User:           # <----------
 *     type: object
 *     required:
 *       - username
 *     properties:
 *       username:
 *         type: string
 *       password:
 *         type: string
 */
/**
 * @swagger
 * components:
 *  schemas:
 *    Login:
 *      type: object
 *      properties:
 *        id:
 *          type: string
 *          format: uuid
 *        username:
 *          type: string
 *        password:
 *          type: string
 *        loginAttemptAt:
 *          type: string
 *          format: date-time
 */

/**
 * Swagger Example:
 *              https://github.com/jellydn/next-swagger-doc/blob/main/example/pages/api/organization.tsx
 *              https://github.com/jellydn/next-swagger-doc/blob/main/example/models/organization.ts
 *              https://swagger.io/docs/specification/describing-request-body/
 */

export default function login(req: NextApiRequest, res: NextApiResponse<Data>) {
  console.log(req);
  if (!req.body) {
    res.statusCode = 404;
    res.end("Error");
    return;
  }
  const { username, password } = req.body;
  res
    .status(200)
    .json({
      id: "3fa85f64-5717-4562-b3fc-2c963f66afa6",
      username: username,
      token: jwt.sign(
        { username, admin: username == "admin" && password == "admin" },
        KEY
      ),
      loginAttemptAt: "2022-10-16T09:45:10.276Z",
    });
}
