// Agent-based slime mold using Structure of Arrays
class SlimeMold {
    constructor(n, h, w) {
        this.count = 0;
        this.count = n;
        this.W = w;
        this.H = h;
        // Agent arrays
        this.x = new Float32Array(n);
        this.y = new Float32Array(n);
        this.angle = new Float32Array(n);
        // Trail maps for diffusion
        this.trailMap = new Float32Array(w * h);
        this.nextTrailMap = new Float32Array(w * h);
        // Initialize agents in a circle at center
        const cx = w / 2;
        const cy = h / 2;
        const radius = Math.min(w, h) * 0.1;
        for (let i = 0; i < n; i++) {
            const a = (i / n) * Math.PI * 2;
            this.x[i] = w * Math.random();
            this.y[i] = h * Math.random();
            this.angle[i] = Math.random() * Math.PI * 2;
        }
    }
    sampleTrail(x, y) {
        const ix = Math.floor(x);
        const iy = Math.floor(y);
        if (ix < 0 || ix >= this.W || iy < 0 || iy >= this.H)
            return 0;
        return this.trailMap[iy * this.W + ix];
    }
    update(brightness, params) {
        const { sensorAngle, sensorDist, turnSpeed, moveSpeed, decayRate, depositAmount, brightnessInfluence } = params;
        const n = this.count;
        const W = this.W;
        const H = this.H;
        // Motor stage: sense and turn
        for (let i = 0; i < n; i++) {
            const x = this.x[i];
            const y = this.y[i];
            const angle = this.angle[i];
            // Three sensors: forward, left, right
            const forwardX = x + Math.cos(angle) * sensorDist;
            const forwardY = y + Math.sin(angle) * sensorDist;
            const leftX = x + Math.cos(angle - sensorAngle) * sensorDist;
            const leftY = y + Math.sin(angle - sensorAngle) * sensorDist;
            const rightX = x + Math.cos(angle + sensorAngle) * sensorDist;
            const rightY = y + Math.sin(angle + sensorAngle) * sensorDist;
            // Sample trail intensity at sensor positions
            let forwardVal = this.sampleTrail(forwardX, forwardY);
            let leftVal = this.sampleTrail(leftX, leftY);
            let rightVal = this.sampleTrail(rightX, rightY);
            // Add image brightness influence (darker = more attractive)
            const sampleBrightness = (sx, sy) => {
                const ix = Math.floor(sx);
                const iy = Math.floor(sy);
                if (ix < 0 || ix >= W || iy < 0 || iy >= H)
                    return 0;
                return 1 - (brightness[iy * W + ix] / 255);
            };
            forwardVal += sampleBrightness(forwardX, forwardY) * (brightnessInfluence / 10);
            leftVal += sampleBrightness(leftX, leftY) * (brightnessInfluence / 10);
            rightVal += sampleBrightness(rightX, rightY) * (brightnessInfluence / 10);
            // Steering behavior
            if (forwardVal > leftVal && forwardVal > rightVal) {
                // Continue forward
            }
            else if (forwardVal < leftVal && forwardVal < rightVal) {
                // Random turn
                this.angle[i] += (Math.random() - 0.5) * 2 * turnSpeed;
            }
            else if (leftVal > rightVal) {
                // Turn left
                this.angle[i] -= turnSpeed;
            }
            else if (rightVal > leftVal) {
                // Turn right
                this.angle[i] += turnSpeed;
            }
            // Move forward
            const newX = x + Math.cos(this.angle[i]) * moveSpeed;
            const newY = y + Math.sin(this.angle[i]) * moveSpeed;
            // Bounce off boundaries
            if (newX < 0 || newX >= W) {
                this.angle[i] = Math.PI - this.angle[i];
            }
            if (newY < 0 || newY >= H) {
                this.angle[i] = -this.angle[i];
            }
            this.x[i] = Math.max(0, Math.min(W - 1, newX));
            this.y[i] = Math.max(0, Math.min(H - 1, newY));
            // Deposit trail - modulated by image darkness
            const ix = Math.floor(this.x[i]);
            const iy = Math.floor(this.y[i]);
            if (ix >= 0 && ix < W && iy >= 0 && iy < H) {
                const idx = iy * W + ix;
                // Darker areas accumulate more trail
                const darknessFactor = 1 - (brightness[idx] / 255);
                const depositVal = depositAmount * (0.3 + darknessFactor * 0.7);
                this.trailMap[idx] = Math.min(1, this.trailMap[idx] + depositVal);
            }
        }
        // Diffusion and decay stage
        for (let y = 1; y < H - 1; y++) {
            for (let x = 1; x < W - 1; x++) {
                const idx = y * W + x;
                // 3x3 blur kernel
                let sum = 0;
                sum += this.trailMap[idx] * 0.25;
                sum += this.trailMap[idx - 1] * 0.125;
                sum += this.trailMap[idx + 1] * 0.125;
                sum += this.trailMap[idx - W] * 0.125;
                sum += this.trailMap[idx + W] * 0.125;
                sum += this.trailMap[idx - W - 1] * 0.0625;
                sum += this.trailMap[idx - W + 1] * 0.0625;
                sum += this.trailMap[idx + W - 1] * 0.0625;
                sum += this.trailMap[idx + W + 1] * 0.0625;
                // Decay
                this.nextTrailMap[idx] = sum * (1 - decayRate);
            }
        }
        // Swap buffers
        const temp = this.trailMap;
        this.trailMap = this.nextTrailMap;
        this.nextTrailMap = temp;
    }
}
export class Slime {
    constructor() {
        this.img = null;
        this.blurredLast = { blur: -1 };
        this.W = 0;
        this.H = 0;
        this.brightness = new Uint8ClampedArray(0);
        this.slimeMold = new SlimeMold(10000, this.W, this.H);
    }
    getConfig() {
        return {
            id: 'slime_mold',
            name: 'Slime Mold',
            controls: [
                { id: 'blur', label: 'Image Blur', min: 0, max: 40, default: 10 },
                { id: 'num_agents', label: 'Agents', min: 1000, max: 100000, default: 20000 },
                { id: 'sensor_angle', label: 'Sensor Angle', min: 0.1, max: 1.5, default: 0.5 },
                { id: 'sensor_dist', label: 'Sensor Distance', min: 1, max: 20, default: 9 },
                { id: 'turn_speed', label: 'Turn Speed', min: 0.1, max: 2, default: 0.8 },
                { id: 'move_speed', label: 'Move Speed', min: 0.5, max: 5, default: 1.5 },
                { id: 'decay_rate', label: 'Decay Rate', min: 0.001, max: 0.2, default: 0.02 },
                { id: 'deposit_amount', label: 'Deposit', min: 0.01, max: 0.5, default: 0.1 },
                { id: 'brightness_influence', label: 'Image Influence', min: 0, max: 10, default: 2 },
            ],
        };
    }
    setSourceImage(img) {
        this.img = img;
        this.W = img.width;
        this.H = img.height;
        if (!this.sourceCanvas)
            this.sourceCanvas = document.createElement('canvas');
        this.sourceCanvas.width = this.W;
        this.sourceCanvas.height = this.H;
        const ctx = this.sourceCanvas.getContext('2d', { willReadFrequently: false });
        if (ctx) {
            const imageData = ctx.createImageData(this.W, this.H);
            imageData.data.set(img.data);
            ctx.putImageData(imageData, 0, 0);
        }
        if (!this.blurredCanvas)
            this.blurredCanvas = document.createElement('canvas');
        this.blurredCanvas.width = this.W;
        this.blurredCanvas.height = this.H;
        this.blurredLast.blur = -1;
        if (!this.trailCanvas)
            this.trailCanvas = document.createElement('canvas');
        this.trailCanvas.width = this.W;
        this.trailCanvas.height = this.H;
        this.trailCtx = this.trailCanvas.getContext('2d', { willReadFrequently: true });
        this.trailImageData = this.trailCtx.createImageData(this.W, this.H);
        this.updateBrightnessMap(0);
    }
    updateBrightnessMap(blur) {
        if (!this.sourceCanvas || !this.blurredCanvas)
            return;
        // Apply blur to source image
        const bctx = this.blurredCanvas.getContext('2d');
        if (!bctx)
            return;
        bctx.clearRect(0, 0, this.W, this.H);
        if (blur > 0) {
            bctx.filter = `blur(${blur}px)`;
        }
        bctx.drawImage(this.sourceCanvas, 0, 0);
        bctx.filter = 'none';
        // Extract brightness from blurred image
        const blurredData = bctx.getImageData(0, 0, this.W, this.H);
        this.brightness = new Uint8ClampedArray(this.W * this.H);
        for (let i = 0; i < this.W * this.H; i++) {
            const r = blurredData.data[i * 4];
            const g = blurredData.data[i * 4 + 1];
            const b = blurredData.data[i * 4 + 2];
            this.brightness[i] = (r + g + b) / 3;
        }
        this.blurredLast.blur = blur;
    }
    reset(params) {
        const numAgents = params?.num_agents ?? 20000;
        this.slimeMold = new SlimeMold(numAgents, this.H, this.W);
    }
    updatesInPlace() {
        return true;
    }
    findBestRectangle(params) {
        const targetAgents = Math.max(1000, params?.num_agents ?? 20000);
        if (!this.img || !this.slimeMold.count || this.slimeMold.count !== targetAgents) {
            this.reset(params);
        }
        // Update brightness map if blur changed
        const blur = Math.max(0, Math.min(40, params.blur ?? 10));
        if (this.blurredLast.blur !== blur) {
            this.updateBrightnessMap(blur);
        }
        // Update slime mold
        this.slimeMold.update(this.brightness, {
            sensorAngle: params.sensor_angle ?? 0.5,
            sensorDist: params.sensor_dist ?? 9,
            turnSpeed: params.turn_speed ?? 0.8,
            moveSpeed: params.move_speed ?? 1.5,
            decayRate: params.decay_rate ?? 0.02,
            depositAmount: params.deposit_amount ?? 0.1,
            brightnessInfluence: params.brightness_influence ?? 2,
        });
        return null;
    }
    getRectangles() {
        return [];
    }
    cullCoveredRectangles() { }
    ensureBlurred(blur) {
        // No longer needed - handled in updateBrightnessMap
    }
    render(ctx, params) {
        if (!this.trailCanvas || !this.trailImageData)
            return;
        // Convert trail map to grayscale image
        const trailData = this.trailImageData.data;
        const trail = this.slimeMold.trailMap;
        for (let i = 0; i < this.W * this.H; i++) {
            const val = Math.floor((1 - trail[i]) * 255);
            trailData[i * 4] = val;
            trailData[i * 4 + 1] = val;
            trailData[i * 4 + 2] = val;
            trailData[i * 4 + 3] = 255;
        }
        this.trailCtx.putImageData(this.trailImageData, 0, 0);
        // Draw trails on black background
        ctx.save();
        ctx.fillStyle = 'black';
        ctx.fillRect(0, 0, this.W, this.H);
        ctx.drawImage(this.trailCanvas, 0, 0);
        ctx.restore();
    }
}
export default Slime;
